#require "Salesforce.class.nut:1.1.0"
#require "Rocky.class.nut:1.2.3"


// ----------------------------------------------------------
// SETUP
// ----------------------------------------------------------


// SALESFORCE CONSTANTS
// ----------------------------------------------------------
const CONSUMER_KEY = "<YOUR CONSUMER KEY>";
const CONSUMER_SECRET = "<YOUR CONSUMER SECRET>";
const LOGIN_HOST = "login.salesforce.com";


// EXTEND SALESFORCE CLASS TO HANDLE OAUTH 2.0
// ----------------------------------------------------------
class ConnectedDevice extends Salesforce {

    // Grab the last part of the Agent's URL and use as an Id
    agentId = split(http.agenturl(), "/").pop();

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
        local url = format("https://%s/services/oauth2/token", LOGIN_HOST);
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
            if (cb) imp.wakeup(0, function() { cb(err, resp, respData); });
        });
    }
}


// INITIALIZE SALESFORCE
// ----------------------------------------------------------

// Create the Salesforce object
force <- ConnectedDevice(CONSUMER_KEY, CONSUMER_SECRET);

// Load existing credential data
oAuth <- server.load();

// Load credentials if we have them
if ("instance_url" in oAuth && "access_token" in oAuth) {
    // Set the credentials in the Salesforce object
    force.setInstanceUrl(oAuth.instance_url);
    force.setToken(oAuth.access_token);

    // Log a message
    server.log("Loaded OAuth Credentials!");
}



// AGENT SIDE OAUTH 2.0 WEB SERVER CODE
// ----------------------------------------------------------

app <- Rocky();

// Define log in endpoint for a GET request to the agent URL
app.get("/", function(context) {
    // Check if an OAuth code was passed in
    if (!("code" in context.req.query)) {
        // If it wasn't, redirect to login service
        local location = format("https://%s/services/oauth2/authorize?response_type=code&client_id=%s&redirect_uri=%s", LOGIN_HOST, CONSUMER_KEY, http.agenturl());
        context.setHeader("Location", location);
        context.send(302, "Found");

        return;
    }

    // Exchange the auth code for inan OAuth token
    force.getOAuthToken(context.req.query["code"], function(err, resp, respData) {
        if (err) {
            context.send(400, "Error authenticating (" + err + ").");
            return;
        }

        // If it was successful, save the data locally
        oAuth = respData;
        server.save(oAuth);

        // Set/update the credentials in the Salesforce object
        force.setInstanceUrl(oAuth.instance_url);
        force.setToken(oAuth.access_token);

        // Finally - inform the user we're done!
        context.send(200, "Authentication complete - you may now close this window");
    });
});



// ----------------------------------------------------------
// APPLICATION CODE
// ----------------------------------------------------------


// RUNTIME VARIABLES
// ----------------------------------------------------------

// The API name
local obj_api_name = "Env_Tail_Reading__c"; // Salesforce object api name where readings are defined


// RUNTIME FUNCTIONS
// ----------------------------------------------------------

// Description: Updates a record in Salesforce
// Parameters: table - the readings table from the device
//             function - callback used to process response from Salesforce
// Return: null
function sendReading(data, cb = null) {
    local url = format("sobjects/%s/DeviceId__c/%s?_HttpMethod=PATCH", obj_api_name, force.agentId);
    local body = {};

    // add salesforce custom object postfix to data keys
    foreach(k, v in data) {
        body[k + "__c"] <- v;
    }

    force.request("POST", url, http.jsonencode(body), cb);
}

// Description: Callback function that handles Salesforce resopnse when posting a reading
// Parameters: error - table if there is an error, null if no error
//             respData - response table from Salesforce
// Return: null
function handleReadingResponse(err, respData) {
    if (err) {
        server.error(http.jsonencode(err));
        return;
    }

    // Log a message for creating/updating a record
    if ("id" in respData) {
        server.log("Created record with id: " + respData.id);
    } else {
        server.log("Updated record with DeviceId: " + force.agentId);
    }
}

// DEVICE LISTENER(S)
// ----------------------------------------------------------

// Check if reading should trigger a case and
device.on("reading", function(reading) {
    // If we're not logged in, do nothing
    if (!force.isLoggedIn()) return;

    // Send reading to Salesforce
    sendReading(reading, handleReadingResponse);
});