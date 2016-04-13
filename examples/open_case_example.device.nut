// Temperature Humidity sensor Library
#require "Si702x.class.nut:1.0.0"
// Ambient Light sensor Library
#require "APDS9007.class.nut:2.2.1"


// ----------------------------------------------------------
// SETUP
// ----------------------------------------------------------

// CONSTANTS
// ----------------------------------------------------------

// How many seconds to wait between sensor readings
const READING_INTERVAL = 3;


// CONFIGURE HARDWARE
// ----------------------------------------------------------

// Pin variables
led <- hardware.pin2;
lxOutPin <- hardware.pin5;
lxEnPin <- hardware.pin7;

// Configuration
led.configure(DIGITAL_OUT, 0);
lxOutPin.configure(ANALOG_IN);
lxEnPin.configure(DIGITAL_OUT, 1);
hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);


// INITIALIZE SENSORS
// ----------------------------------------------------------

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
function takeReadings() {
    local data = {};

    // Take a sync temp/humid reading
    local thReading = tempHumid.read();
    if ("err" in thReading) {
        server.error("Temperature/Humidity Sensor.  Error reading temperature & humidity. "+ thReading.err);
    } else {
        data.temperature <- thReading.temperature;
        data.humidity <- thReading.humidity;
        server.log(format("temperature: %0.2f°C \nhimidity: %0.2f%s", data.temperature, data.humidity, "%"));
    }

    // Take a sync light reading
    // Note on first boot up this take 5sec before a reading is returned
    // This is expected
    local lxReading = ambLight.read();
    if("err" in lxReading) {
        server.error("Amblient Light Sensor.  Error reading light Level. " + lxReading.err);
    } else {
        data.amb_lx <- lxReading.brightness;
        server.log(format("Light Level = %0.2f lux", data.amb_lx));
    }

    // Send readings stored in the data table to agent
    agent.send("reading", data);

    // Wait for time set in READING_INTERVAL then take another set of readings
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