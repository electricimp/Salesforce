// MIT License
//
// Copyright 2017 Electric Imp
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

// Temperature Humidity sensor Library
#require "HTS221.device.lib.nut:2.0.1"

// Class to configure and take readings from Explorer Kit sensors.
// Take readings from temperature humidity and light sensors.
// Use the light level to determine if the door is open (true or false)
// and send the door status, temperature and humidity to the agent 
class SmartFridge {

    // Time in seconds to wait between readings
    static READING_INTERVAL_SEC = 15;

    // The lx level at which we know the door is open
    static LX_THRESHOLD         = 9000;

    // Sensor variables
    tempHumid = null;

    constructor() {
        // Power save mode will reduce power consumption when the 
        // radio is idle. This adds latency when sending data. 
        imp.setpowersave(true);
        initializeSensors();
    }

    function run() {
        // Set up the reading table with a timestamp
        local reading = { "ts" : time() };
        
        // Add temperature and humidity readings
        local result = tempHumid.read();
        if ("temperature" in result) reading.temperature <- result.temperature;
        if ("humidity" in result) reading.humidity <- result.humidity;

        // Check door status using internal LX sensor to 
        // determine if the door is open
        reading.doorOpen <- (hardware.lightlevel() > LX_THRESHOLD);

        // Send readings to the agent
        agent.send("reading", reading);

        // Schedule the next reading
        imp.wakeup(READING_INTERVAL_SEC, run.bindenv(this));
    }

    function initializeSensors() {
        // Configure i2c
        local impType = imp.info();
        local i2c = null;
        switch(impType.type) {
            case "imp001":
                i2c = hardware.i2c89;
                server.log("imp001 detected, using i2c89");
                break;
            case "imp003":
                i2c = hardware.i2cAB;
                server.log("imp003 detected, using i2cAB");
                break;
            case "imp004m":
                i2c = hardware.i2cQP;
                server.log("imp004m detected, using i2cQP");
                break;
            default:
                server.log("Unsupported imp: " + impType.type);
        }
        i2c.configure(CLOCK_SPEED_400_KHZ);

        // Initialize sensor
        tempHumid = HTS221(i2c);

        // Configure sensor to take readings
        tempHumid.setMode(HTS221_MODE.ONE_SHOT); 
    }
}


// RUNTIME 
// ---------------------------------------------------
server.log("Device running...");

// Initialize application
fridge <- SmartFridge();

// Start reading loop
fridge.run();
