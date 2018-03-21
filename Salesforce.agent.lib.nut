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


class Salesforce {

    // Library version
    static VERSION = "2.0.0";

    // service URLs
    _loginServiceBase = "https://login.salesforce.com/";
    _loginService = "/services/oauth2/token"

    // Instance URL returned by login service
    _instanceUrl = null
    _baseApi = "/services/data/";
    _version = "v33.0";

    // Security
    _clientId = null;       // Consumer Key
    _clientSecret = null;   // Consumer Secret
    _token = null;          // Password Token

    _refreshToken = null;    // OAuth Refresh Token

    _userUrl = null;        // URL to get info about logged in user

    // Set OAuth tokens
    constructor(consumerKey, consumerSecret, loginServiceBase = null, salesforceVersion = null) {
        _clientId = consumerKey;
        _clientSecret = consumerSecret;

        if (loginServiceBase != null) _loginServiceBase = loginServiceBase;
        if (salesforceVersion != null) _version = salesforceVersion;
    }

    function setLoginService(loginService) {
        _loginServiceBase = loginService;
    }

    function setVersion(versionString) {
        _version = versionString;
    }

    function setInstanceUrl(url) {
        _instanceUrl = url;
    }

    function setToken(token) {
        _token = token;
    }

    function login(username, password, securityToken = null, cb = null) {
        // Add token if required
        if (securityToken != null) password = password+securityToken;

        local url = format("%s%s", _loginServiceBase, _loginService);
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };
        local data = {
            "grant_type": "password",
            "client_id": _clientId,
            "client_secret": _clientSecret,
            "username": username,
            "password": password
        }

        local req = http.post(url, headers, http.urlencode(data));
        if (cb != null) {
            _processRequest(req, function(err, data) {
                if (err != null) {
                    cb(err, { result = false });
                    return;
                }
                try {
                    this._userUrl = data.id;
                    this._instanceUrl = data.instance_url;
                    this._token = data.access_token;
                    if("refresh_token" in data) this._refreshToken = data.refresh_token;
                } catch (ex) {
                    cb([{"errorCode": "NO_AUTH", "message": "Could not find auth token with supplied login information"}], null);
                    return;
                }

                cb(null, { result = true });
                return;
            }.bindenv(this));
        } else {
            local resp = _processRequest(req);
            local err = resp.err;
            local data = resp.data;

            if (err != null) {
                return { err = err, data = null };
            }
            try {
                    this._userUrl = data.id;
                    this._instanceUrl = data.instance_url;
                    this._token = data.access_token;
                    if("refresh_token" in data) this._refreshToken = data.refresh_token;
            } catch (ex) {
                return { err = [{"errorCode": "NO_AUTH", "message": "Could not find auth token with supplied login information"}], data = null };
            }
            return { err = null, data = {result = true } };
        }
    }

    function isLoggedIn() {
        return (_token != null);
    }

    function getRefreshToken() {
        return _refreshToken;
    }

    function getUser(cb = null) {
        if(!isLoggedIn()) throw "AUTH_ERR: No authentication information."

        local headers = {
            "Authorization": "Bearer " + _token,
            "content-type": "application/json",
            "accept": "application/json"
        }

        local req = http.get(_userUrl, headers);
        return _processRequest(req, cb);
    }

    function request(verb, service, body = null, cb = null) {
        if(!isLoggedIn()) throw "AUTH_ERR: No authentication information.";

        // Make sure the body isn't null
        if (body == null) body = "";

        local url = format("%s%s%s/%s", _instanceUrl, _baseApi, _version, service);
        local headers = {
            "Authorization": "Bearer " + _token,
            "content-type": "application/json",
            "accept": "application/json"
        }

        local req = http.request(verb, url, headers, body);
        return _processRequest(req, cb);
    }

    /******************** PRIVATE METHODS ********************/
    function _processRequest(req, cb = null) {
        if (cb != null) {
            return req.sendasync(function(resp) {
                local data = {};

                try { data = http.jsondecode(resp.body); }
                catch (ex) { data = { }; }

                if (resp.statuscode >= 200 && resp.statuscode < 300) {
                    cb(null, data);
                } else {
                    cb(data, null);
                }
            }.bindenv(this));
        } else {
            local resp = req.sendsync();
            local data = http.jsondecode(resp.body);
            if (resp.statuscode >= 200 && resp.statuscode < 300) {
                return { err = null, data = data };
            } else {
                return { err = data, data = null };
            }
        }
    }
}
