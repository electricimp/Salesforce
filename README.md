#Salesforce
This library wraps the [Force.com REST API](https://www.salesforce.com/us/developer/docs/api_rest/). Force.com is a suite of point-and-click tools that make creating custom employee-facing apps lightning fast. The Electric Imp Salesforce library enables you to interact with your Force.com objects, allowing you to easily create products that can interact with a powerful CRM backend.

## Callbacks
All methods that make requests to the Force.com API can be called asyncronously (by providing the optional callback) or syncronously (by not provinding the callback). If a callback is supplied, it must take two parameters: *err*, and *data*. If no errors were encountered, *err* will be null and *data* will contain the result of the request. If an error occured during the request, *err* will contain the error inforamtion, and *data* will be null.

If no callback is supplied (i.e. a syncronous request was made), the method will return a table containing *err*, and *data* and follow the same conventions as above.

**NOTE**: If you receive an error with an *errorCode* of "INVALID_SESSION_ID" it means that your login is no longer valid (or you never logged in).

## constructor(consumerKey, consumerSecret, [loginService], [version])
To create a new Salesforce object you will need the Consumer Key and Consumer Secret of a Connected App. Information about creating a Connected App can be found [here](https://help.salesforce.com/apex/HTViewHelpDoc?id=connected_app_create.htm). The constructor also allows you to pass in two additional parameters to override defaults: loginService (default value is "login.salesforce.com") and version (default value is "v33.0").

```squirrel
#require "Salesforce.class.nut:1.0"

force <- Salesforce("<-- CONSUMER_KEY -->", "<-- CONSUMER_SECRET -->");
```

## force.login(username, password, [securityToken], [callback])
Once you've created a Salesforce object, you need to provide the login credentials via the **login** method. The login method requires a *username*, *password*, and optional *securityToken* (information about acquiring your security token can be found [here](https://help.salesforce.com/apex/HTViewHelpDoc?id=user_security_token.htm)), and can be supplied with an additional optional callback (see note [above](#callbacks)) that will be executed upon the completion of the login request.

The data from the *login* method consists of a table with a single field - *result*, which contains a boolean value indicating whether or not the login was successful.

```squirrel
force.login(USERNAME, PASSWORD, SECURITY_TOKEN, function(err, data) {
    if (err != null) {
        // if there was an error, log it
        server.error (err);
        return;
    }

    // if the login failed
    if(data.result == false) {
        server.error("Could not login");
        return;
    }

    // do things after logging in:
    // ...
 });
```

## force.isLoggedIn()
The **isLoggedIn** method immediately returns a boolean value indicating whether or not the Salesforce object has completed a login requests and stored the authentication token.

## force.setVersion(versionString)
The **setVersion** method can be used to set/change what version of the Force.com REST API you are working with:

```squirrel
force.setVersion("v27.0");  // set to v27.0 instead of v33.0
```

## force.setLoginService(loginService)
The **setLoginService** method can be used to set/change what endpoint the Salesforce object uses in it's login requests:

```squirrel
//const ENVIRONMENT = LIVE;
const ENVIRONMENT = "TEST";

// if we're not using our live Salesforce instance:
if (ENVIRONMENT == "TEST") {
    force.setLoginService("https://test.salesforce.com");
}

// Login...
```

## force.getRefreshToken()
The **getRefreshToken** will return the authentication's [refresh_token](https://help.salesforce.com/HTViewHelpDoc?id=remoteaccess_oauth_refresh_token_flow.htm&language=en_US) (if it exists). If the login flow did not result in a refresh_token, or a succesfull call to **login** has not been made yet, this method will return ```null```.

## force.getUser([callback])
The **getUser** method makes a request to Salesforce to retreive information about the currently logged in user. If a successful call to the **login** method has not yet occured, an error will be thrown.

```squirrel
force.login(USERNAME, PASSWORD, SECURITY_TOKEN, function(err, data) {
    if (err != null || (data != null && data.result == false)) {
        server.error("Could not login to Salesforce");
        return;
    }

    force.getUser(function(err, data) {
        if (err) {
            server.error("ERROR: " + http.jsonencode(err));
            return;
        }

        // if it worked, log all the information we have about the user
        foreach(idx, val in data) {
            server.log(idx + ": " + val);
        }
    });
});
```

## force.request(verb, service, [body], [callback])
The **request** method is the most basic way of interacting with objects in your Salesforce database. It creates an HTTP request with properly formated authentication headers, etc. If a successful call to the **login** method has not yet occured, an error will be thrown.

The data from the *request* method will be the parsed body of the request's response. In the example below, we are fetching a set of custom objects (campsites) from our Salesforce database:

```squirrel
force.login(USERNAME, PASSWORD, SECURITY_TOKEN, function(err, data) {
    if (err != null || (data != null && data.result == false)) {
        server.error("Could not login to Salesforce");
        return;
    }
    force.request("get", "sobjects/campsites__c", null, function(err, data) {
        if (err) {
            server.error("ERROR: " + http.jsonencode(err));
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
});
```

#License
The Salesforce library is licensed under the [MIT License](./LICENSE).
