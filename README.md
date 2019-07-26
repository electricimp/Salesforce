# Salesforce 3.0.0 #

This library wraps the [Force.com REST API](https://www.salesforce.com/us/developer/docs/api_rest/). Force.com is a suite of point-and-click tools for creating custom employee-facing apps. The Electric Imp Salesforce library enables you to interact with your Force.com objects, allowing you to easily create products that can interact with a powerful CRM backend.

**Note** Release v3.0.0 contains breaking changes to support authentication using the Electric Imp's [OAuth2 Library](https://github.com/electricimp/OAuth-2.0). If you are not using OAuth2 library for authentication you can continue to use [v2.0.1](https://github.com/electricimp/Salesforce/releases/tag/v2.0.1-docs)

**To add this library to your project, add** `#require "Salesforce.agent.lib.nut:3.0.0"` **to the top of your agent code.**

## Class Usage ##

### Callbacks ###

All methods that make requests to the Force.com API can be called asynchronously (by providing the optional callback function) or synchronously (by not providing the callback). If a callback is supplied, it must take two parameters: *err* and *data*. If no errors were encountered, *err* will be `null` and *data* will contain the parsed HTTP response body. If an error occurred during the request, *err* will contain an error message and *data* will contain either the raw un-parsed HTTP response or `null` if HTTP response data is not available.

If no callback is supplied (ie. a synchronous request was made), the method will return a table containing two fields, *err* and *data*, which follow the same conventions as outlined above.

### Constructor: Salesforce(*[salesforceAPIVersion]*) ##

The constructor configures basic Force API settings. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *salesforceAPIVersion* | String | No | The version string used in HTTP requests to Salesforce. Default: "v46.0" |

```squirrel
force <- Salesforce();
```

## Class Methods ##

### login(*auth[, callback]*) ###

The login method is used to obtain authorization credentials required for Force.com API requests. If login is successful authorization credentials will be stored locally in the library instance for use in requests.  

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *auth* | Table | Yes | Table of authorization settings &mdash; see [**Authorization Settings**](#authorization-settings), below  |
| *callback* | Function | Yes | See [Class Usage: Callbacks](#callbacks) for details |

#### Authorization Settings ####

Required authorization settings include Salesforce account and [Connected Application](https://help.salesforce.com/apex/HTViewHelpDoc?id=connected_app_create.htm) credentials. If you are working in a Salesforce sandbox environment, you should set the *authUrl* to `"https://login.salesforce.com/services/oauth2/token"`.

| Key | Type | Required? | Description |
| --- | --- | --- | --- |
| *username* | String | Yes | Salesforce account username |
| *password* | String | Yes | Salesforce account password |
| *clientId* | String | Yes | Salesforce Connected App Consumer Key |
| *clientSecret* | String | Yes | Salesforce Connected App Consumer Secret |
| *securityToken* | String | No | A security token. See [here](https://help.salesforce.com/apex/HTViewHelpDoc?id=user_security_token.htm) for information about acquiring your security token. |
| *authUrl* | String | No | Salesforce login service endpoint. Default: `"https://login.salesforce.com/services/oauth2/token"` |

#### Example ####

```squirrel
auth <- {
    "username"     : "user@example.com",
    "password"     : "worstpasswordever",
    "clientId"     : "<YOUR_CONNECTED_APP_CONSUMER_KEY>",
    "clientSecret" : "<YOUR_CONNECTED_APP_CONSUMER_SECRET>", 
    "authUrl"      : "https://login.salesforce.com/services/oauth2/token"
}

force.login(auth, function(err, data) {
    if (err != null) {
        // There was an error obtaining authorization credentials
        // Log error
        server.error (err);
        return;
    }

    // Do things after logging in...
 });
```

### processAuthResp(*httpResponse*) ###

When authenticating via a method other than login, ie OAuth2, the HTTP response can be passed into this method to parse and update library instance's stored authentication settings required for making requests. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *httpResponse* | Table | Yes | The response table passed into HTTP doneCallback or returned by a HTTP synchronous request |

#### Return Value ####

Table &mdash; A parsed response with the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *err* | String or `null` | If an error was encounter, a string with a message describing the error |
| *data* | Table | If an error was encountered the un-parsed response, otherwise a table containing the parsed response body |

#### Example ####

```squirrel
// OAuth2 Get Token callback
function onGetOAuthToken(token, err, resp) {
    if (err) {
        server.error("Error retrieving Salesforce auth: " + err);
        return;
    }

    local parsed = force.processAuthResp(resp);
    if (parsed.err) {
        server.error(parsed.err);
        return;
    }

    server.log("Salesforce authorization succeeded");
    // TODO: Use parsed.data to persist authentication credentials  
    // for use across agent reboots
}
```

### isLoggedIn() ###

This method immediately returns a boolean value indicating whether or not there is a stored authentication token.

#### Return Value ####

Boolean &mdash; whether there is currently a stored authentication token.

#### Example ####

```squirrel
if (!force.isLoggedIn()) {
    server.log("Missing Salesforce credentials. Please login.");
}
```

### setVersion(*versionString*) ###

This method can be used to set or change the version of the Force.com REST API you are working with. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *versionString* | String | Yes | A version string, for example: `"v33.0"` |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// Set to v33.0 instead of v46.0 (the default)
force.setVersion("v33.0");  
```

### setToken(*token*) ###

This method can be used to manually set the authorization token the library instance uses in its requests. When authenticating via a method other than login, ie OAuth2, the authorization token can be found in the authentication response under "access_token" key. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *token* | String | Yes | A Salesforce authentication token |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// OAuth2 Get Token callback
function onGetOAuthToken(token, err, resp) {
    if (err) {
        server.error("Error retrieving Salesforce auth: " + err);
        return;
    }

    force.setToken(token);
}
```

### setUserId(*id*) ###

This method can be used to manually set or change the URL the library instance uses when sending request to get user information. When authenticating via a method other than login, ie OAuth2, the user id can be found in the authentication response under "id" key and is formatted as a URL containing an id. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *id* | String | Yes | A Salesforce authentication token |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// OAuth2 Get Token callback
function onGetOAuthToken(token, err, resp) {
    if (err) {
        server.error("Error retrieving Salesforce auth: " + err);
        return;
    }

    force.setToken(token);

    if (resp != null) {
        try {
            local body = http.jsondecode(resp.body);
            if ("id" in body) {
                local usrId = body.id;
                server.log("User Id: " + usrId);
                force.setUserId(usrId);
            } else {
                server.error("Response did not include an id: " + resp.body);
            }
        } catch(e) {
            server.error("Unable to parse Salesforce response: " + e);
        }
    }
}
```

### setInstanceUrl(*url*) ###

This method can be used to manually set or change the URL the library instance uses when sending requests. When authenticating via a method other than login, ie OAuth2, the instance url can be found in the authentication response under "instance_url" key. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *url* | String | Yes | The Salesforce endpoint used to send requests for the authenticated user |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// OAuth2 Get Token callback
function onGetOAuthToken(token, err, resp) {
    if (err) {
        server.error("Error retrieving Salesforce auth: " + err);
        return;
    }

    force.setToken(token);

    if (resp != null) {
        try {
            local body = http.jsondecode(resp.body);
                if ("instance_url" in body) {
                    local url = body.instance_url;
                    server.log("Instance URL: " + url);
                    force.setInstanceUrl(url);
                } else {
                    server.error("Response did not include an instance url: " + resp.body");
                }
        } catch(e) {
            server.error("Unable to parse Salesforce response: " + e);
        }
    }
}
```

### setRefreshToken(*refreshToken*) ###

This method can be used to set or change the refresh token when necessary. When authenticating via a method other than login, ie OAuth2, the refresh token can be found in the authentication response under "refresh_token" key. Note, not all authorization methods will include a refresh token.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *refreshToken* | String | Yes | A Salesforce refresh token |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// OAuth2 Get Token callback
function onGetOAuthToken(token, err, resp) {
    if (err) {
        server.error("Error retrieving Salesforce auth: " + err);
        return;
    }

    force.setToken(token);

    if (resp != null) {
        try {
            local body = http.jsondecode(resp.body);
            if ("refresh_token" in body) {
                force.setRefreshToken(body.refresh_token);
            }
        } catch(e) {
            server.error("Unable to parse Salesforce response: " + e);
        }
    }
}
```

### getRefreshToken() ###

This method will return the library instance's stored authentication’s [refresh token](https://help.salesforce.com/HTViewHelpDoc?id=remoteaccess_oauth_refresh_token_flow.htm&language=en_US) if it exists. If the authorization flow used did not result in a refresh token or if no authentication flow has been invoked this method will return `null`.

#### Return Value ####

Nothing.

#### Example ####

```squirrel
local refresh = force.getRefreshToken();
if (refresh != null) {
    server.log(refresh);
}
```

### getUser(*[callback]*) ###

This method makes a request to Salesforce to retrieve information about the user who is currently logged in. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *callback* | Function | Yes | See [Class Usage: Callbacks](#callbacks) for details |

#### Return Value ####

Table or `null` &mdash; See [Class Usage: Callbacks](#callbacks) for details.

#### Example ####

```squirrel
if (force.isLoggedIn()) {
    force.getUser(function(err, data) {
        if (err) {
            server.error(err);
            return;
        }

        // If it worked, log all the information we have about the user
        foreach(index, value in data) {
            server.log(index + ": " + value);
        }
    }
}
```

### request(*verb, service[, body][, callback]*) ###

This method is the most basic way of interacting with objects in your Salesforce database. It creates an HTTP request with properly formated authentication headers, etc. 

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *callback* | Function | Yes | See [Class Usage: Callbacks](#callbacks) for details |

#### Return Value ####

Table or `null` &mdash; See [Class Usage: Callbacks](#callbacks) for details.

#### Example ####

In the example below, we are fetching data from a custom object (campsites) in our Salesforce database.

**Note** If you receive an error with an *errorCode* of `"INVALID_SESSION_ID"` it means that your login is no longer valid (or that you never logged in).

```squirrel
const SF_OBJECT_NAME = campsites__c;

if (force.isLoggedIn()) {
    local service = format("sobjects/%s", SF_OBJECT_NAME);

    force.request("GET", service, null, function(err, data) {
        if (err) {
            server.error(err);
            if (data != null && "body" in data) server.log(data.body);
            return;
        }

        // Log the names of all the recent campsites
        if ("recentItems" in data) {
            server.log("Recent Campsites: ");
            foreach(campsite in data.recentItems) {
                server.log(campsite.Name);
            }
        }
    });
}
```

## License ##

The Salesforce library is licensed under the [MIT License](./LICENSE).
