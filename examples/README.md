#Salesforce Examples

The following examples will use a Salesforce Connected App for communication between the Imp and Salesforce.  These examples require you to have an [Electric Imp developer account](https://ide.electricimp.com/login), the Electric Imp BlinkUp app, a [Salesforce developer account](https://developer.salesforce.com/signup?d=70130000000td6N), and the hardware listed below.

## Hardware

Both examples will use an Imp 001, an April breakout board, and an Environmental Sensor tail to collect data.  Developer kits with these parts can be purchased on [Amazon](http://www.amazon.com/WiFi-Environmental-Sensor-LED-kit/dp/B00ZQ4D1TM/ref=sr_1_1?ie=UTF8&qid=1459988822&sr=8-1&keywords=electric+imp+kit).  If you need guides to help you get started with Electric Imp visit the [Dev Center](https://electricimp.com/docs/gettingstarted/).


## Getting Started

Choose the example you wish to use, then create a model in the Electric Imp IDE, and assign your device to that model.  Copy and paste the corresponding example code into the agent and device coding windows.  Select your device and make a note of your agent url, which can be found at the top of your model's agent code.  It will look something like this ```"https://agent.electricimp.com/szPc0sLfAqlu"```.  You will need the agent url when creating your connected app in Salesforce.


###Creating a Connected App in Salesforce

Step by step instructions to create a Connected App:

  - Log into Salesforce and click on the **Setup** tab in the top right navigation menu
  - In the sidebar under **Build** unfold the **Create** menu and select **Apps**
  - At the bottom of the page under **Connected apps** click the **New** button
  - In the **New Connected App** form fill in:
    - Basic Information
      - Connected App Name
      - API Name
      - Contact Email
    - API (Enable OAuth Settings)
      - Check the *Enable OAuth Settings* Box
      - Callback URL - this should be your agent url
      - Selected OAuth Scopes
        - Select *Access and manage your data (api)*
        - then click *Add*
    - When above info is filled out click **Save**
  - You will be redirected to the *Connected App Name - your app name* page
    - Make a note of your Consumer Key (you will need to enter this into your agent code)
    - Click on Consumer Secret *Click to reveal*
    - Make note of your Consumer Secret (you will need to enter this into your agent code)

Open the Electric Imp IDE & select your device.  Find the *SALESFORCE CONSTANTS* section in the Agent code and enter your Consumer Key and Consumer Secret.

**Note:** These instructions were written 3/16 and may not be accurate if Salesforce updates their web portal.

##Open a Case Example

In this example the Imp will open a case in Salesforce if the device triggers an event.  The device takes a temperature, humidity, and ambient light reading every 3 seconds then passes the readings to the agent.  The agent runs some logic to determine if the temperature has gone above 29°C or below 20°C, or if the ambient light has gone below 20 lux.  If any of these conditions have been met a case will be opened in Salesforce with the details of the event that triggered the case.


##Custom Object Example

Imp will update a record in Salesforce every 60 seconds.  The device takes a temperature, humidity, air pressure, and ambient light reading every 60 seconds then passes those readings to the agent.  The agent then updates the Salesforce record with the new readings.

### Creating a Custom Object in Salesforce

This example takes a bit more setup in Salesforce.  You will need to create a custom object with fields that correspond to each reading.

log into your salesforce developer account
click setup
open the schema builder

create a new custom object - show attribute settings

add fields - show this - need to match device

add text field with device id - show this


##Launching App

These examples uses OAuth 2.0 for authentication, so the agent has been set up as a web server to handle the log in.
Go to the Electric Imp IDE and select your device for the final setup steps.

- Hit **Build and Run** to save and launch the code
- Click on the agent url (at the top of the agent coding window) to launch the log in page
- Log into salesforce

Your App should now be up and running.  You can monitor the device logs in the IDE, or log into Salesforce web prortal to see updates there.