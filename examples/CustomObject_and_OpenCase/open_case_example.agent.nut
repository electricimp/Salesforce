#require "Salesforce.agent.lib.nut:2.0.0"
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

// Event varaiable used to define limits for each sensor that should open a case
// Keys should correspond to the keys used in the device readings data table
event_limits <- { "temperature" : {"min": 20, "max": 29, "unit" : "°C"},
                  "amb_lx" : {"min": 20, "max": null, "unit": " lux"} };


// RUNTIME FUNCTIONS
// ----------------------------------------------------------

// Description: Opens a case in Salesforce
// Parameters: string - subject line for case
//             string - description line(s) for case
//             function - callback used to process response from Salesforce
// Return: null
function openCase(subject, description, cb = null) {
    local data = {
        "Subject": subject,
        "Description": description
    };

    force.request("POST", "sobjects/Case", http.jsonencode(data), cb);
}

// Description: Callback function that handles Salesforce response when opening a case
// Parameters: error - table if there is an error, null if no error
//             data - response table from Salesforce
// Return: null
function handleCaseResponse(err, data) {
    if (err) {
        server.error(http.jsonencode(err));
        return;
    }

    server.log("Created case with id: " + data.id);
}

// Description: Utility function to determine if reading has exeded defined limits
// Parameters: table - containing readings from the device
//             integer/float or null - min threshold (if reading is below or equal to min it will trigger Salesforce case)
//             integer/float or null - max threshold (if reading is above or equal to max it will trigger Salesforce case)
// Return: a table with keys:
//      "event" - a boolean if event occured
//      "type" - a string "high" or "low", or null
function checkLimits(reading, min, max) {
    local event = false;
    local type = null;
    if(min == null) {
        if(reading >= max) {
            event = true;
            type = "Reading above High Limit";
        }
    } else if (max == null) {
        if(reading <= min) {
            event = true;
            type = "Reading below Low Limit";
        }
    } else {
        if (reading <= min) {
            event = true;
            type = "Reading below Low Limit";
        } else if (reading >= max) {
            event = true;
            type = "Reading above High Limit";
        }
    };
    return { "event" : event, "type": type};
}

// Description: Use limits variable to check if reading should open a Salesforce case
// Parameter: table of readings
// Return: null
function checkEvents(reading) {
    foreach (sensor, limit in event_limits) {
        if(sensor in reading) {
            local e = checkLimits(reading[sensor], limit.min, limit.max);
            if(e.event) {
                server.log("Event triggered.")
                local subject = format("%s sensor %s event", sensor, e.type);
                local description = format("Agent Id: %s \r\nSensor: %s \r\nEvent: %s \r\nReading: %0.2f%s", force.agentId, sensor, e.type, reading[sensor], limit.unit);
                openCase(subject, description, handleCaseResponse);
            }
        }
    }
}


// DEVICE LISTENER(S)
// ----------------------------------------------------------

// Check if reading should trigger a case and
device.on("reading", function(reading) {
    // If we're not logged in, do nothing
    if (!force.isLoggedIn()) return;

    // Open Salesforce Case if event found
    if (event_limits.len() > 0) checkEvents(reading);
});