// Temperature Humidity sensor Library
#require "Si702x.class.nut:1.0.0"
// Air Pressure sensor Library
#require "LPS25H.class.nut:2.0.1"

// Ambient Light sensor Class
class APDS9007 {

    static version = [2,0,2];

    // For accurate readings time needed to wait after enabled
    static ENABLE_TIMEOUT = 5;

    static ERR_SENSOR_NOT_ENABLED = "Sensor is not enabled. Call enable() before reading.";
    static ERR_SENSOR_NOT_READY = "Sensor is not ready.";

    // value of load resistor on ALS (device has current output)
    _rload              = null;
    _als_pin            = null;
    _als_en             = null;

    _points_per_read    = null;
    _ready_at           = null;

    constructor(als_pin, rload, als_en = null) {
        _als_pin = als_pin;
        _als_en = als_en;
        _rload = rload;
        _points_per_read = 10.0;

        // enable sensor if no enable pin is passed in
        if(_als_en == null) _ready_at = time() + ENABLE_TIMEOUT;
    }

    // enable/disable sensor
    function enable(state = true) {
        if (_als_en && state) {
            _als_en.write(1);
            _ready_at = time() + ENABLE_TIMEOUT;
        }
        if (_als_en && !state) {
            _als_en.write(0);
            _ready_at = null;
        }
    }

    function getPointsPerReading() {
        return _points_per_read
    }

    function setPointsPerReading(points) {
        // Force to a float
        if (typeof points == "integer" || typeof points == "float") {
            _points_per_read = points * 1.0;
        }
        return _points_per_read;
    }

    // read the ALS
    function read(cb = null) {
        local result = {};
        if(_ready_at == null) {
            result = {"err" : ERR_SENSOR_NOT_ENABLED};
            // Return table if no callback was passed
            if (cb == null) { return result; }
            // Invoke the callback if one was passed
            imp.wakeup(0, function() { cb(result); }.bindenv(this));
        } else if( time() >= _ready_at ) {
            result = { "brightness" : _getBrightness() };
            // Return table if no callback was passed
            if (cb == null) { return result; }
            // Invoke the callback if one was passed
            imp.wakeup(0, function() { cb(result); }.bindenv(this));
        } else {
            if (cb == null) {
                local errMsg = format("%s  Please try again in %i seconds.", ERR_SENSOR_NOT_READY, _ready_at - time())
                return { "err" : errMsg };
            } else {
                // take a reading when device is ready
                imp.wakeup(_ready_at - time(), function() {
                    read(cb);
                }.bindenv(this));
            }
        }
    }

    function _getBrightness() {
        local Vpin = 0;
        local Vcc = 0;

        // average several readings for improved precision
        for (local i = 0; i < _points_per_read; i++) {
            Vpin += _als_pin.read();
            Vcc += hardware.voltage();
        }

        Vpin = (Vpin * 1.0) / _points_per_read;
        Vcc = (Vcc * 1.0) / _points_per_read;
        Vpin = (Vpin / 65535.0) * Vcc;

        local Iout = (Vpin / _rload) * 1000000.0; // current in µA

        return math.pow(10.0,(Iout/10.0));
    }

}


// ----------------------------------------------------------
// SETUP
// ----------------------------------------------------------

// CONSTANTS
// ----------------------------------------------------------

// How many seconds to wait between sensor readings
const READING_INTERVAL = 60;


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
    // Note on first boot up this will throw an error - sensor not ready
    // This is expected, the sensor takes 5sec before an accurate reading can be taken
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