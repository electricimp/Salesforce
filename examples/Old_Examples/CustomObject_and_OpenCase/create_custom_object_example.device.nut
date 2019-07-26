// Temperature Humidity sensor Library
#require "Si702x.class.nut:1.0.0"
// Air Pressure sensor Library
#require "LPS25H.class.nut:2.0.1"
// Ambient Light sensor Library
#require "APDS9007.class.nut:2.2.1"


// ----------------------------------------------------------
// SETUP
// ----------------------------------------------------------

// CONSTANTS
// ----------------------------------------------------------

// How many seconds to wait between sensor readings
const READING_INTERVAL = 300;


// CONFIGURE HARDWARE
// ----------------------------------------------------------

// Pin variables
local led = hardware.pin2;
local lxOutPin = hardware.pin5;
local lxEnPin = hardware.pin7;

// Configuration
led.configure(DIGITAL_OUT, 0);
lxOutPin.configure(ANALOG_IN);
lxEnPin.configure(DIGITAL_OUT, 1);
hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);


// INITIALIZE SENSORS
// ----------------------------------------------------------

pressure <- LPS25H(hardware.i2c89);
tempHumid <- Si702x(hardware.i2c89);
ambLight <- APDS9007(lxOutPin, 47000, lxEnPin);
ambLight.enable();


// RUNTIME FUNCTIONS
// ----------------------------------------------------------

// Reading loop
//  Each sensor takes a reading
//  All sensor readings are sent to the Agent
//  LED flashes to let user know readings are being sent
//  Loop time is set by the READING_INTERVAL constant
// NOTE: the slot names in the data table must match the Field Names in the Salesforce Custom Object
function takeReadings() {
    // The slot names in this table must match the Field Names in the Salesforce Custom Object
    local data = {};

    // take a sync temp/humid reading
    local thReading = tempHumid.read();
    if ("err" in thReading) {
        server.error("Error reading temperature. "+ thReading.err);
    } else {
        // Temperature Reading Field Name now set to temperature
        data.temperature <- thReading.temperature;
        // Humidity Reading Field Name now set to humidity
        data.humidity <- thReading.humidity;
        server.log(format("Got temperature: %0.2f°C \nhimidity: %0.2f", data.temperature, data.humidity));
    }

    // take a sync pressure reading
    pressure.enable(true);
    local pReading = pressure.read();
    if ("err" in pReading) {
        server.error("Error reading pressure. "+ pReading.err);
    } else {
        // Air Pressure Reading Field Name now set to pressure
        data.pressure <- pReading.pressure;
        server.log(format("Got pressure: %0.2fhPa", data.pressure));
    }

    // Take a sync light reading
    // Note on first boot up this take 5sec before a reading is returned, this is expected
    local lxReading = ambLight.read();
    if("err" in lxReading) {
        server.error("Error reading Light Level. "+lxReading.err);
    } else {
        // Ambient Light Reading Field Name now set to amb_lx
        data.amb_lx <- lxReading.brightness;
        server.log(format("Light Level = %0.2flux", data.amb_lx));
    }

    agent.send("reading", data);

    imp.wakeup(READING_INTERVAL, takeReadings);

    flashLed();
}

// Flash LED
function flashLed() {
    led.write(1);
    imp.sleep(0.5);
    led.write(0);
}


// RUNTIME
// ----------------------------------------------------------

// Start off the sensor reading loop
takeReadings();