// The MIT License (MIT)

// Copyright (c) 2015-18 Electric Imp

// SPDX-License-Identifier: MIT

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

const SALESFORCE_DEFAULT_LOGIN_SERVICE = "https://login.salesforce.com/services/oauth2/token";
const SALESFORCE_DEFAULT_BASE_API_PATH = "/services/data";
const SALESFORCE_DEFAULT_API_VERSION   = "v46.0";

class Salesforce {

    // Library version
    static VERSION = "3.0.0";

    // Used to create request URL
    _instanceUrl      = null;   // returned by login service
    _apiVer           = null;

    // URL to get info about logged in user
    _userUrl          = null;   // returned by login service (id)

    // Security
    _token            = null;   // Password Token
    _refreshToken     = null;   // OAuth Refresh Token

    // Configure API settings
    constructor(verStr = SALESFORCE_DEFAULT_API_VERSION) {
        _apiVer = verStr;
    }

    function setVersion(verStr) {
        _apiVer = verStr;
    }

    function setUserId(id) {
        _userUrl = id;
    }

    function setInstanceUrl(url) {
        _instanceUrl = url;
    }

    function setToken(token) {
        _token = token;
    }

    function setRefreshToken(refreshToken) {
        _refreshToken = refreshToken;
    }

    function getRefreshToken() {
        return _refreshToken;
    }

    function getUser(cb = null) {
        // Check that we have everything needed to make request
        local errMsg = ""; 
        if (!isLoggedIn()) errMsg += "No authentication information";            
        if (_userUrl == null) {
            errMsg += (errMsg.len() > 0) ? " and missing user id" : "Missing user id";
        }
        // Handle error if we found one
        if (errMsg.len() > 0) {
            local err = "[Salesforce] Error retrieving user information: " + errMsg;
            if (cb) {
                cb(err, null);
                return;
            } else {
                return {"err" : err, "data" : null};
            }
        }

        local headers = {
            "Authorization": "Bearer " + _token,
            "content-type": "application/json",
            "accept": "application/json"
        }

        local req = http.get(_userUrl, headers);
        return _processRequest(req, cb);
    }

    function login(creds, cb = null) {
        // Make sure we have the credentials needed
        if (!("username" in creds) || !("password" in creds) || !("clientId" in creds) || 
            !("clientSecret" in creds)) {
            // Cannot login without required credentials, return error
            local err = "[Salesforce] Login failed. Missing one or more credentials: username, password, clientId and clientSecret";
            if (cb == null) return {"err" : err, "data" : null};
            cb(err, null);
            return;
        }

        // Add token if required
        local password = ("securityToken" in creds) ? creds.securityToken + creds.password : creds.password;
        // Use default or user specified login URL
        local url = ("authUrl" in creds) ? creds.authUrl : SALESFORCE_DEFAULT_LOGIN_SERVICE;
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };
        local data = {
            "grant_type"    : "password",
            "client_id"     : creds.clientId,
            "client_secret" : creds.clientSecret,
            "username"      : creds.username,
            "password"      : password
        }

        local req = http.post(url, headers, http.urlencode(data));
        return _processRequest(req, processAuthResp, cb);
    }

    // Note callback parameter is only needed for use with library's 
    // login method, public function should always return the table 
    function processAuthResp(resp, cb = null) {
        // Parse HTTP response body, returns table - err, data
        local parsed = _parseResponse(resp);

        // Only process reponse data if no error has occurred
        if (parsed.err == null) {
            try {
                local body = parsed.data;
                _instanceUrl = body.instance_url;
                _token = body.access_token;
                if ("id" in body) _userUrl = body.id;
                if ("refresh_token" in body) _refreshToken = body.refresh_token;
            } catch (e) {
                parsed.err = "[Salesforce] Login failed. Could not find auth token or instanceUrl with supplied login information. Error:  " + e;
            }
        }

        if (cb == null) return parsed;
        cb(parsed.err, parsed.data); 
    }

    function isLoggedIn() {
        return (_token != null);
    }

    function request(verb, service, body = null, cb = null) {
        if (!isLoggedIn()) {
            local err = "[Salesforce] Error sending request: No authentication information";
            if (cb) {
                cb(err, null);
                return;
            } else {
                return {"err" : err, "data" : null};
            }
        }

        // Make sure the body isn't null
        if (body == null) body = "";

        local url = format("%s%s/%s/%s", _instanceUrl, SALESFORCE_DEFAULT_BASE_API_PATH, _apiVer, service);
        local headers = {
            "Authorization": "Bearer " + _token,
            "content-type": "application/json",
            "accept": "application/json"
        }

        local req = http.request(verb, url, headers, body);
        return _processRequest(req, _parseResponse, cb);
    }

    /******************** PRIVATE METHODS ********************/

    function _processRequest(req, onResp, cb) {
        if (cb != null) {
            return req.sendasync(function(resp) {
                onResp(resp, cb);
            }.bindenv(this));
        } else {
            local resp = req.sendsync();
            return onResp(resp);
        }
    }

    function _parseResponse(resp, cb = null) {
        local err  = null;
        local data = resp;
        try { 
            if (!(resp.statuscode >= 200 && resp.statuscode < 300)) {
                err = "[Salesforce] Unexpected response from server, Status Code: " + resp.statuscode;
            } else {
                data = http.jsondecode(resp.body); 
            }
        } catch (e) { 
            err = "[Salesforce] Error processing response from server, Error: " + e;
        }

        // Return parsed response/error
        if (cb == null) return {"err" : err, "data" : data};

        // Pass response to callback
        cb(err, data);
    }

}
