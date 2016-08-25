#Salesforce Smart Refrigerator

The following Trailhead project will use an Electric Imp to monitor a refrigerator and a Salesforce *Connected App* to track the current temperature and humidity in the fridge.  This example will also *open a case* in Salesforce if:  1) the refrigerator door is open for more than 30 seconds, or 2) the temperature remains over 11°C for more than 15 min, or 3) the relative humidity is over 70% for more than 15 min.  To track the current temperature and humidity we will create a Salesforce *custom object*, then update it with new readings every 15 sec.


## What you need

### General
 - Your WIFI *network name* and *password*
 - A smartphone (iOS or Android)
 - A computer with a web browser

### Accounts
  - An [Electric Imp developer account](https://ide.electricimp.com/login)
  - The Electric Imp BlinkUp app ([iOS](https://itunes.apple.com/us/app/electric-imp/id547133856) or [Android](https://play.google.com/store/apps/details?id=com.electricimp.electricimp))
  - A [Salesforce developer account](https://developer.salesforce.com/signup?d=70130000000td6N)

### Hardware
  - An Electric Imp developer kit - to purchase email saleforce.devkit@electricimp.com
  - [USB AC adapter](https://www.amazon.com/Omni-Universal-Adapter-Charger-Samsung/dp/B00YG0QALS/ref=sr_1_2?ie=UTF8&qid=1470954944&sr=8-2&keywords=usb+ac+adapter+5v)
  - [Electrical tape](https://www.amazon.com/Duck-299006-4-Inch-Utility-Electrical/dp/B001B19JLS/ref=sr_1_1?s=industrial&ie=UTF8&qid=1470867277&sr=1-1)

## Getting Started

### Hardware Setup
 - Plug the imp001 into the breakout board
 - Connect the Env Sensor tail to the April breakout board
 - Power up your Imp with the USB cable and power adapter
 - The imp001 should now have power and be blinking amber/red

<img src="http://i.imgur.com/erBvo7d.jpg" width="400">

### Electric Imp BlinkUp

Use the Electric Imp mobile app to BlinkUp your device

 - Log into your Electric Imp account
 - Enter your WIFI credentials
 - Follow the instructions in the app to [BlinkUp](https://electricimp.com/platform/blinkup/) your device

### Electric Imp IDE / Code
 - In your favorite web browser log into the [Electric Imp IDE](https://ide.electricimp.com/login)
 - Click the *Create New Model* button
 - In the pop up name your code model, select your device and click *Create Model* button
 - Copy and paste the Salesforce Trailhead example code into the agent and device coding windows.  The agent.nut file should go in the agent coding window, the device.nut file in the device coding window.
 - In the sidebar select your device (this should open up a device logs window under the agent and device coding windows)
 - At the top of your agent coding window there is now an agent url. It will look something like this ```"https://agent.electricimp.com/szPc0sLfAqlu"```
 - Make a note of your agent url. You will need the it when creating your connected app in Salesforce.

 ![IDE code windows](http://i.imgur.com/d0eO0TP.png)

If you need guides to help you get started with Electric Imp visit the [Dev Center](https://electricimp.com/docs/gettingstarted/).

### Creating a Connected App in Salesforce

Step by step instructions to create a Connected App:

  1. Log into Salesforce and click on the **Setup** tab in the top right navigation menu
  ![Salesforce Navbar](http://i.imgur.com/mhYIfBx.png)
  2. In the sidebar under **Build** unfold the **Create** menu and select **Apps**
  3. At the bottom of the page under **Connected apps** click the **New** button
  ![Salesforce Apps](http://i.imgur.com/40aXTlL.png)
  4. In the **New Connected App** form fill in:
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
  5. You will be redirected to the *Connected App Name - your app name* page
    - Make a note of your Consumer Key (you will need to enter this into your agent code)
    - Click on Consumer Secret *Click to reveal*
    - Make note of your Consumer Secret (you will need to enter this into your agent code)
  ![Salesforce Keys](http://i.imgur.com/uussyzV.png)

Open the Electric Imp IDE & select your device.  Find the *SALESFORCE CONSTANTS* section at the bottom of the Agent code and enter your **Consumer Key** and **Consumer Secret**.

![IDE with code](http://i.imgur.com/hvligYx.png)


### Creating a Custom Object in Salesforce

You will need to create a custom object with fields that correspond to each reading.  Step by step instructions for creating a Custom Object:

1. Log into Salesforce and click on the **Setup** tab in the top right navigation menu
![Salesforce Navbar](http://i.imgur.com/mhYIfBx.png)
2. In the sidebar under **Build** unfold the **Create** menu and select **Objects**
3. At the top of the page click the **New Custom Object** button
![Salesforce Custom Object](http://i.imgur.com/FhF0J8w.png)
4. In the **New Custom Object** form fill in:
    - Custom Object Information
      - **Label** - for example *Frig_Reading*
      - **Plural Label** - for example *Frig_Readings*
      - **Object Name** - for example *Frig_Reading*
    - Enter Record Name Label and Format
      - **Record Name** - for example *Reading Id*
      - **Data Type** select **Auto Number**
      - **Display Format** - for example *R-{0000}*
    - When above info is filled out click **Save**
5. On the **Custom Objects Page** click on your object name
6. You will be redirected to the *Custom Object - your object name* page <br> You will repeat step 7 four times to add fields for each sensor reading collected <br> The **Field Name** must match the data table from the device. The **Field Names** in the exmple code are: **temperature**, **humidity** , **door**, **ts**.
7. At the bottom of the page under **Custom Fields & Relationships** click the **New** button
    - Step 1 *Data Type*
      - Select **Number** for temperature and humidity, **Text** for door, or **Date/Time** for ts
      - then click **Next** button
    - Step 2 of 4
      - Enter **Field Label** - for example *temperature*, *humidity*, *door*, or *ts*
      - Enter **Length** - for temperature and humidity *4*, for door *10*
      - Enter **Decimal Places** - for temperature and humidity *2*
      - Enter **Field Name** - this must match the keys from the device code, *temperature*, *humidity*, *door*, or *ts*
      - Enter **Description** - for example *Temperature reading in °C*
      - then click **Next** button
    - Step 3 of 4
      - click **Next** button
    - Step 4 of 4
      - click **Save & New** <br>
      **Repeat** Steps 1-4 for humidity,
8. We need to create one more Field the *Device Id field*
    - Step 1 *Data Type*
      - Select **text**
      - then click **Next** button
    - Step 2 of 4
      - Enter **Field Label** enter **deviceId**
      - Enter **Length** - for example *16*
      - Enter **Field Name** enter **deviceId**
      - check **Required**
      - check **Unique**
      - check **Test "ABC" and "abc" as different values (case sensitive)**
      - check **External ID**
      - then click **Next** button
    - Step 3 of 4
      - click **Next** button
    - Step 4 of 4
      - click **Save**
9. You will be redirected to the *Custom Object - your object name* page
    - Make a note of your **API Name** (you will need to enter this into your agent code)
![Salesforce API Name](http://i.imgur.com/tL6ar7Z.png)

Open the Electric Imp IDE & select your device.  Find the *SALESFORCE CONSTANTS* section at the bottom of the Agent code and enter your **OBJ_API_NAME**. You are now ready to [launch your app](#launching-app).

![IDE with code](http://i.imgur.com/hvligYx.png)


##Launching App

These examples use OAuth 2.0 for authentication, so the agent has been set up as a web server to handle the log in.
Go to the Electric Imp IDE and select your device from the sidebar for the final setup steps.

- Hit **Build and Run** to save and launch the code
- Click on the agent url (at the top of the agent coding window) to launch the log in page
- Log into salesforce

![IDE Screenshot](http://i.imgur.com/kMU3Qio.png)

Your App should now be up and running.  You can monitor the device logs in the IDE, or log into Salesforce web prortal to see updates there.

##Install Hardware

Open your refrigerator and tape the Imp and Env Tail inside with the sensors facing away from the refrigerator ceiling/wall.

Run the USB cable to the outside of the refrigerator and plug into power.

<img src="http://i.imgur.com/BUuEpjt.png" width="400">