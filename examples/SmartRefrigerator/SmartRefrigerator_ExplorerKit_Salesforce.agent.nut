// MIT License
//
// Copyright 2017 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

// Utility Libraries
#require "Rocky.class.nut:1.2.3"

// Web Integration Library
#require "Salesforce.class.nut:1.1.0"

// Extends Salesforce Library to handle authorization
class SalesforceOAuth2 extends Salesforce {

    _login = null;

    constructor(consumerKey, consumerSecret, loginServiceBase = null, salesforceVersion = null) {
        _clientId = consumerKey;
        _clientSecret = consumerSecret;

        if ("Rocky" in getroottable()) {
            _login = Rocky();
        } else {
            throw "Unmet dependency: SalesforceOAuth2 requires Rocky";
        }

        if (loginServiceBase != null) _loginServiceBase = loginServiceBase;
        if (salesforceVersion != null) _version = salesforceVersion;

        getStoredCredentials();
        defineLoginEndpoint();
    }

    function getStoredCredentials() {
        local persist = server.load();
        local oAuth = {};
        if ("oAuth" in persist) oAuth = persist.oAuth;

        // Load credentials if we have them
        if ("instance_url" in oAuth && "access_token" in oAuth) {
            // Set the credentials in the Salesforce object
            setInstanceUrl(oAuth.instance_url);
            setToken(oAuth.access_token);

            // Log a message
            server.log("Loaded OAuth Credentials!");
        }
    }

    function defineLoginEndpoint() {
        // Define log in endpoint for a GET request to the agent URL
        _login.get("/", function(context) {

            // Check if an OAuth code was passed in
            if (!("code" in context.req.query)) {
                // If it wasn't, redirect to login service
                local location = format(
                    "%s/services/oauth2/authorize?response_type=code&client_id=%s&redirect_uri=%s",
                    _loginServiceBase,
                    _clientId, http.agenturl());
                context.setHeader("Location", location);
                context.send(302, "Found");

                return;
            }

            // Exchange the auth code for inan OAuth token
            getOAuthToken(context.req.query["code"], function(err, resp, respData) {
                if (err) {
                    context.send(400, "Error authenticating (" + err + ").");
                    return;
                }

                // If it was successful, save the data locally
                local persist = { "oAuth" : respData };
                server.save(persist);

                // Set/update the credentials in the Salesforce object
                setInstanceUrl(persist.oAuth.instance_url);
                setToken(persist.oAuth.access_token);

                // Finally - inform the user we're done!
                context.send(200, "Authentication complete - you may now close this window");
            }.bindenv(this));
        }.bindenv(this));
    }

    // OAuth 2.0 methods
    function getOAuthToken(code, cb) {
        // Send request with an authorization code
        _oauthTokenRequest("authorization_code", code, cb);
    }

    function refreshOAuthToken(refreshToken, cb) {
        // Send request with refresh token
        _oauthTokenRequest("refresh_token", refreshToken, cb);
    }

    function _oauthTokenRequest(type, tokenCode, cb = null) {
        // Build the request
        local url = format("%s/services/oauth2/token", _loginServiceBase);
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };
        local data = {
            "grant_type": type,
            "client_id": _clientId,
            "client_secret": _clientSecret,
        };

        // Set the "code" or "refresh_token" parameters based on grant_type
        if (type == "authorization_code") {
            data.code <- tokenCode;
            data.redirect_uri <- http.agenturl();
        } else if (type == "refresh_token") {
            data.refresh_token <- tokenCode;
        } else {
            throw "Unknown grant_type";
        }

        local body = http.urlencode(data);

        http.post(url, headers, body).sendasync(function(resp) {
            local respData = http.jsondecode(resp.body);
            local err = null;

            // If there was an error, set the error code
            if (resp.statuscode != 200) err = data.message;

            // Invoke the callback
            if (cb) {
                imp.wakeup(0, function() {
                    cb(err, resp, respData);
                });
            }
        });
    }
}

// Door status strings
const DOOR_OPEN = "open";
const DOOR_CLOSED = "closed";

// Application code, listen for readings from device,
// when a reading is received send the data to Salesforce
class SmartFridgeApplication {

    _force = null;
    _deviceID = null;
    _sendReadingUrl = null;

    constructor(key, secret, readingEventName) {
        _deviceID = imp.configparams.deviceid.tostring();
        _sendReadingUrl = format("sobjects/%s/", readingEventName);
        _force = SalesforceOAuth2(key, secret, null, "v40.0");
        device.on("reading", readingHandler.bindenv(this));
    }

    // Sends the data received from device, to Salesforce as Platform Event.
    function readingHandler(data) {
        // Log the reading from the device
        server.log(http.jsonencode(data));

        local body = { "deviceId__c" : _deviceID };

        // add Salesforce fields postfix to data keys and convert values if needed
        foreach (key, value in data) {
            if (key == "ts") {
                value = formatTimestamp(value);
            }
            if (key == "doorOpen") {
                key = "door";
                value = value ? DOOR_OPEN : DOOR_CLOSED;
            }
            body[key + "__c"] <- value;
        }

        // don't send if we are not logged in
        if (!_force.isLoggedIn()) {
            server.error("Not logged into Salesforce.")
            return;
        }
        // Send Salesforce platform event with device readings
        _force.request("POST", _sendReadingUrl, http.jsonencode(body), function (err, respData) {
            if (err) {
                server.error(http.jsonencode(err));
            }
            else {
                server.log("Readings sent successfully");
            }
        });
    }

    // Converts timestamp to "2017-12-03T00:54:51Z" format
    function formatTimestamp(ts = null) {
        local d = ts ? date(ts) : date();
        return format("%04d-%02d-%02dT%02d:%02d:%02dZ", d.year, d.month + 1, d.day, d.hour, d.min, d.sec);
    }
}

// RUNTIME
// ---------------------------------------------------------------------------------

// SALESFORCE CONSTANTS
// ----------------------------------------------------------
const CONSUMER_KEY = "<YOUR_CONSUMER_KEY_HERE>";
const CONSUMER_SECRET = "<YOUR_CONSUMER_SECRET_HERE>";
const READING_EVENT_NAME = "Smart_Fridge_Reading__e";

// Start Application
SmartFridgeApplication(CONSUMER_KEY, CONSUMER_SECRET, READING_EVENT_NAME);
