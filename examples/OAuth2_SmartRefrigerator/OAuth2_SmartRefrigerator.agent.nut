// MIT License
//
// Copyright 2019 Electric Imp
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

// INCLUDE LIBRARIES
// ---------------------------------------------------------------------------------
#require "Rocky.class.nut:1.2.3"
// #require "OAuth2.agent.lib.nut:2.1.0"
// #require "Salesforce.agent.lib.nut:3.0.0"
@include "github:electricimp/Salesforce/Salesforce.agent.lib.nut@develop"
@include "github:electricimp/OAuth-2.0/OAuth2.agent.lib.nut@develop"

// SALESFORCE CONSTANTS
//
// NOTE: Please replace values of these constants with real user credentials
// ---------------------------------------------------------------------------------
// SHARED OAUTH CREDENTIALS
const CONSUMER_KEY       = "<YOUR CONNECTED APP CONSUMER KEY>";
const READING_EVENT_NAME = "Smart_Fridge_Reading__e";

// DEVICE FLOW OAUTH CREDENTIALS
const CONSUMER_SECRET    = "<YOUR CONNECTED APP CONSUMER SECRET>";

// JWT FLOW OAUTH CREDENTIALS
const JWT_PIVATE_KEY     = "<YOUR JWT PRIVATE KEY>";
const SF_USERNAME        = "<YOUR SALESFORCE USERNAME>";

// ---------------------------------------------------------------------------------


// PERSIST STORAGE CLASS 
// ---------------------------------------------------------------------------------

enum PERSIST_ERASE_SCOPE {
    ALL,
    SF_AUTH,
    SF_TOKEN,
    SF_AUTH_TYPE,
    SF_INSTANCE_URL, 
    SF_USER_ID
}

// Manages Persistant Storage  
// Dependencies: Agent storage (ie server.save, server.load)
class Persist {

    _persist = null;
    _sfAuth = null;

    constructor() {
        _persist = server.load();
        if ("sfAuth" in _persist) { 
            _sfAuth = _persist.sfAuth;
        } else {
            _sfAuth = {};
        }
    }

    function erase(scope = PERSIST_ERASE_SCOPE.ALL) {
        // Update class vars
        switch(scope) {
            case PERSIST_ERASE_SCOPE.ALL:
                _persist = {};
                break;
            case PERSIST_ERASE_SCOPE.SF_AUTH:
                if ("sfToken" in _persist) _persist.rawdelete("sfToken");
                _sfAuth = {};
                _persist.sfAuth <- _sfAuth;
                break;
            case PERSIST_ERASE_SCOPE.SF_TOKEN:
                if ("sfToken" in _persist) _persist.rawdelete("sfToken");
                if ("token" in _sfAuth) _sfAuth.rawdelete("token");
                _persist.sfAuth <- _sfAuth;
                break;
            case PERSIST_ERASE_SCOPE.SF_AUTH_TYPE:
                if ("type" in _sfAuth) _sfAuth.rawdelete("type");
                _persist.sfAuth <- _sfAuth;
                break;
            case PERSIST_ERASE_SCOPE.SF_INSTANCE_URL:
                if ("instURL" in _sfAuth) _sfAuth.rawdelete("instURL");
                _persist.sfAuth <- _sfAuth;
                break;
            case PERSIST_ERASE_SCOPE.SF_USER_ID:
                if ("usrId" in _sfAuth) _sfAuth.rawdelete("usrId");
                _persist.sfAuth <- _sfAuth;
                break;
        }
        // Update agent persistant storage
        server.save(_persist);
    }

    function getSFToken() {
        return ("token" in _sfAuth) ? _sfAuth.token : null;
    }

    function setSFToken(token) {
        if (token != getSFToken()) {
            ::debug("[Persist] Updating stored salesforce token.");
            _sfAuth.token <- token;
            _storeSFAuth();
        }
    }

    function getSFInstanceURL() {
        return ("instURL" in _sfAuth) ? _sfAuth.instURL : null;
    }

    function setSFInstanceURL(instURL) {
        if (instURL != getSFInstanceURL()) {
            ::debug("[Persist] Updating stored salesforce instance URL.");
            _sfAuth.instURL <- instURL;
            _storeSFAuth();
        }
    }

    function getSFIUserId() {
        return ("usrId" in _sfAuth) ? _sfAuth.instURL : null;
    }

    function setSFUserId(usrId) {
        if (usrId != getSFIUserId()) {
            ::debug("[Persist] Updating stored salesforce User Id.");
            _sfAuth.usrId <- usrId;
            _storeSFAuth();
        }
    }

    function getSFAuthType() {
        return ("auth" in _sfAuth) ? _sfAuth.auth : null;
    }

    function setSFAuthType(auth) {
        if (auth != getSFAuthType()) {
            ::debug("[Persist] Updating stored salesforce auth type.");
            _sfAuth.auth <- auth;
            _storeSFAuth();
        }
    }

    function _storeSFAuth() {
        _persist.sfAuth <- _sfAuth;
        server.save(_persist);
    }

}


// OAUTH 2.0 DEVICE FLOW SUPPORTING CLASS 
// ---------------------------------------------------------------------------------

// HTML to display when agent url is clicked
{
    html <- @"<!doctype html>

    <html lang='en'>
    <head>
    <meta charset='utf-8'>

    <title>Electric Imp Salesforce Device</title>
    <meta name='description' content='Electric Imp Salesforce Connect Device'>
    <meta name='author' content='Electric Imp'>

    <style type='text/css'>
        document {
        font-family: sans-serif;
        }
        .grid {  
        display: grid;
        grid-template-columns: 10% 80% 10%;
        height: 100vh;
        width: 100vw;
        }
        .container {
        text-align: center;
        margin-top: 5%;
        grid-column-start: 2;
        grid-column-end: 3;
        grid-row-start: 1;
        grid-row-end: 2;
        }
        .hidden {
        position: absolute;
        left: -10000px;
        }
        .copy-target {
        color: #307cc1;
        background-position: right;
        background-repeat: no-repeat;
        background-size: contain;
        padding-right: 1.25em;
        background-image: url('data:image/png;base64,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')
        }
        .copy-target:hover {
            cursor: pointer;
        }
    </style>

    </head>

    <body>
    <div class='grid'>
        <div class='container'>
        <h1>Device Authentication</h1>
        <input type='text' class='hidden' id='copy' value='%s' />
        <a class='code copy-target' onClick='copy_me()'>%s</a>
        <p class='info'>Click the code above to copy to your clipboard, then follow the link below</p>
        <p>
            <a href='%s' id='auth-link'>Enter Code Link</a>
        </p>
        </div>
    </div>
    <script type='text/javascript'>
        function copy_me() {
        var copyText = document.getElementById('copy');
        copyText.select();
        document.execCommand('copy');
        }
    </script>
    </body>
    </html>";
}

const SF_OAUTH_DEVICE_CODE_DEFAULT = "XXXXXXXX";
const SF_OAUTH_DEVICE_URL_DEFAULT  = "https://login.salesforce.com/setup/connect";

class SalesForceOAuth2Device {

    _client    = null;
    _webserver = null;

    _authUrl   = null;
    _devCode   = null;

    constructor() {
        local userConfig = { 
            "clientId"     : CONSUMER_KEY,
            "clientSecret" : CONSUMER_SECRET,
            "scope"        : "api refresh_token"
        };

        local providerConfig = {
            "loginHost" : SALESFORCE_DEFAULT_LOGIN_SERVICE, 
            "tokenHost" : SALESFORCE_DEFAULT_LOGIN_SERVICE,
            "grantType" : "device"
        }

        local settings = {
            "includeResp"    : true,
            "addReqCodeData" : {"response_type" : "device_code"} 
        }

        _client = OAuth2.DeviceFlow.Client(providerConfig, userConfig, settings);

        // Set defaults for device code webpage 
        clearCode();

        _webserver = Rocky();
        _webserver.get("/", onRoot.bindenv(this));
    }

    function getToken(cb) {
        local token = _client.getValidAccessTokenOrNull();
        if (token != null) {
            // We have a valid token already
            server.log("[SalesForceOAuth2Device] Salesforce access token aquired.");
            cb(null, token, null);
        } else {
            // Acquire a new access token
            local status = _client.acquireAccessToken(
                function(token, err, resp) {
                    cb(err, token, resp);
                }.bindenv(this), 
                function(url, code) {
                    _authUrl = url;
                    _devCode = code;
                    server.log("-------------------------------------------------------------------------------------");
                    server.log("[SalesForceOAuth2Device] Salesforce: Authorization is pending. Please grant access");
                    server.log("[SalesForceOAuth2Device] Auth URL: " + url);
                    server.log("[SalesForceOAuth2Device] Device Code: " + code);
                    server.log("[SalesForceOAuth2Device] Agent URL: " + http.agenturl();
                    server.log("-------------------------------------------------------------------------------------");
                }.bindenv(this)
            );

            if (status != null) server.error("[SalesForceOAuth2Device] Salesforce: Client is already performing request (" + status + ")");
        }
    }

    function onRoot(context) {
        context.send(200, format(html, _devCode, _devCode, _authUrl));
    }

    function clearCode() {
        _authUrl = SF_OAUTH_DEVICE_URL_DEFAULT;
        _devCode = SF_OAUTH_DEVICE_CODE_DEFAULT;
    }

}

// OAUTH 2.0 JWT FLOW SUPPORTING CLASS 
// ---------------------------------------------------------------------------------

class SalesForceOAuth2JWT {

    _client = null;

    constructor() {
        // NOTE: 365 day cert created on 6/18/19
        local userSettings = { 
            "iss"        : CONSUMER_KEY,
            "jwtSignKey" : JWT_PIVATE_KEY, 
            "sub"        : SF_USERNAME
        };

        local providerSettings = {
            "tokenHost" : SALESFORCE_DEFAULT_LOGIN_SERVICE
        }

        local settings = {
            "includeResp" : true
        }

        _client = OAuth2.JWTProfile.Client(providerSettings, userSettings, settings);
    }

    function getToken(cb) {
        local token = _client.getValidAccessTokenOrNull();
        if (token != null) {
            // We have a valid token already
            server.log("[SalesForceOAuth2JWT] Salesforce access token aquired.");
            cb(null, token, null);
        } else {
            // Acquire a new access token
            _client.acquireAccessToken(function(newToken, err, resp) {
                cb(err, newToken, resp);
            }.bindenv(this));
        }
    }
}

// SMART FRIDGE APPLICATION CLASS 
// ---------------------------------------------------------------------------------

// Door status strings
const DOOR_OPEN = "open";
const DOOR_CLOSED = "closed";

enum SF_AUTH_TYPE {
    JWT, 
    DEVICE
}

enum SF_ERROR_CODES {
    MISSING_FIELD      = "REQUIRED_FIELD_MISSING",
    INVALID_SESSION_ID = "INVALID_SESSION_ID"
}

// Application code, listen for readings from device,
// when a reading is received send the data to Salesforce
class SmartFridgeApplication {

    _force           = null;
    _oauth           = null;
    _persist         = null;

    _sendReadingPath = null;
    _impDeviceId     = null;
    _authType        = null;

    constructor(authType) {
        _impDeviceId = imp.configparams.deviceid;
        _sendReadingPath = format("/sobjects/%s/", READING_EVENT_NAME);

        // Create persistant storage instance
        _persist = Persist();

        // Select DEVICE or JWT Authentication
        _authType = authType;
        if (_authType != _persist.getSFAuthType()) {
            // Erase stored Salesforce auth data if we have changed how
            // we are authenticating
            _persist.erase(PERSIST_ERASE_SCOPE.SF_AUTH);
            _persist.setSFAuthType(_authType);
        }

        _force = Salesforce();
        local instanceURL = _persist.getSFInstanceURL();
        if (instanceURL != null) _force.setInstanceUrl(instanceURL);

        // Authorize device
        authorize();

        // Open Reading Listener
        device.on("reading", onDeviceReading.bindenv(this));
    }

    // Sends the data received from device, to Salesforce as Platform Event.
    function onDeviceReading(data) {
        // Don't send if we are not logged in
        if (!_force.isLoggedIn()) {
            server.log("[SmartFridegeApp] Not logged into Salesforce. Not sending data: " + http.jsonencode(data));
            return;
        }

        local body = { "deviceId__c" : _impDeviceId };

        // Add Salesforce fields postfix to data keys and convert values if needed
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

        // Log the data being sent to the cloud
        server.log(http.jsonencode(body));

        // Send Salesforce platform event with device readings
        _force.request("POST", _sendReadingUrl, http.jsonencode(body), onSFReadingSent.bindenv(this));
    }

    function onSFReadingSent(err, respData) {
        if (err) {
            server.log("[SmartFridegeApp] Salesforce reporting error occurred: ");
            server.error(err);
        } else {
            server.log("[SmartFridegeApp] Salesforce readings sent successfully");
        }
    }

    function authorize() {
        local token = _persist.getSFToken();
        if (token != null) {
            // Set token
            _force.setToken(token);

            // Ping Saleforce to see if token is valid
            // NOTE: Device as identified via imp device id must have already be  
            // configured in Salesforce or ping will fail
            local pingData = { [SF_EVENT_DEV_ID] = _impDeviceId };
            _force.request("POST", _sendReadingPath, http.jsonencode(pingData), onAuthPing.bindenv(this));
        } else {
            triggerOAuthFlow();
        }
    }

    function onAuthPing(err, resp) {
        if (err != null) { 
            server.log("[SmartFridegeApp] " + err);

            try {
                local errCode = getErrorCode(resp);
                server.log("[SmartFridegeApp] ping error code: " + errCode);

                switch (errCode) {
                    case SF_ERROR_CODES.MISSING_FIELD:
                        server.log("[SmartFridegeApp] Used stored token to authorize device with Salesforce");
                        return;
                    case SF_ERROR_CODES.INVALID_SESSION_ID:
                        server.log("[SmartFridegeApp] Stored token expired");
                        break;
                    default: 
                        server.log("[SmartFridegeApp] Salesforce send ping unexpected error occurred: ");
                        ::error(resp.body);
                }
            } catch(e) {
                server.log("[SmartFridegeApp] ping error unable to parse response: " + e);
            }

            // Our stored token is bad, erase it from storage and SF instance
            server.log("[SmartFridegeApp] Erasing stored token. Starting new authentication with Salesforce.");
            _persist.setSFToken(null);
            _force.setToken(null);
            // Try to re-authorize
            triggerOAuthFlow();
        } else {
            server.log("[SmartFridegeApp] Used stored token to authorize device with Salesforce, statuscode: " + resp.statuscode);
        }
    }

    function triggerOAuthFlow() {
        switch (_authType) {
            case SF_AUTH_TYPE.JWT:
                server.log("[SmartFridegeApp] OAuth type: JWT");
                _oauth = SalesForceOAuth2JWT();
                break;
            case SF_AUTH_TYPE.DEVICE:
            server.log("[SmartFridegeApp] OAuth type: DEVICE");
                _oauth = SalesForceOAuth2Device();
                break;
            default: 
                server.error("[SmartFridegeApp] Unexpected authorization type. Not logging into Salesforce");
        }

        // Authorize device/get token
        _oauth.getToken(onGetOAuthToken.bindenv(this))
    }

    function onGetOAuthToken(err, token, resp) {
        // Polling concluded, clear devicde code so webpage doesn't display 
        // stale data
        if (_authType == SF_AUTH_TYPE.DEVICE) _oauth.clearCode();

        if (err) {
            server.error("[SmartFridegeApp] Unable to log into Salesforce: " + err);
            return;
        }

        if (resp != null) {
            local parsed = _force.processAuthResp(resp);
            if (parsed.err == null) {
                local body = parsed.data;
                _persist.setSFToken(token);
                _persist.setSFInstanceURL(body.instance_url);
                if ("id" in body) _persist.setSFUserId(body.id);
            } else {
                server.error("[SmartFridegeApp] Unable parse Salesforce auth response: " + parsed.err);
            }
        } else {
            server.log("[SmartFridegeApp] Token handler did not contain HTTP response");
        }

    }

    function getErrorCode(resp) {
        try {
            // Try to parse response to get an error code
            local body = http.jsondecode(resp.body);
            local e = (typeof body == "array") ? body[0] : body;
            local errIsTable = (typeof e == "table");

            return (errIsTable && "errorCode" in e) ? e.errorCode : null;
        } catch(e) {
            server.error("[SmartFridegeApp] Error parsing response: " + e);
            return null;
        }
    }

    // Converts timestamp to "2017-12-03T00:54:51Z" format
    function formatTimestamp(ts = null) {
        local d = ts ? date(ts) : date();
        return format("%04d-%02d-%02dT%02d:%02d:%02dZ", d.year, d.month + 1, d.day, d.hour, d.min, d.sec);
    }

}

// RUNTIME
// ---------------------------------------------------------------------------------

// Start Application
// Select Auth type SF_AUTH_TYPE.DEVICE or SF_AUTH_TYPE.JWT
SmartFridgeApplication(SF_AUTH_TYPE.DEVICE);
