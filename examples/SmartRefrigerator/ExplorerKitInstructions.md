# Salesforce Smart Refrigerator

The following Trailhead project will use the Electric Imp platform to connect and monitor a refrigerator and a Salesforce *Connected App* to track the current temperature and humidity in the fridge.

To track the current temperature and humidity we will create a Salesforce *Custom Object* and put readings data to it every 15 seconds using Salesforce *Platform Events*.

This example will also *open a Case* in Salesforce using *IoT Explorer Orchestration* if: 
1. the refrigerator door is opened for more than 30 seconds (??? predefined threshold), or 
2. the temperature is over predefined threshold, or 
3. the relative humidity is over predefined threshold.

## Step 1: Intro - What you need

### General
 - Your WIFI *network name* and *password*
 - A smartphone (iOS or Android)
 - A computer with a web browser

### Accounts
  - An [Electric Imp developer account](https://preview-impcentral.electricimp.com/login)
  - The Electric Imp BlinkUp<sup>TM</sup> app ([iOS](https://itunes.apple.com/us/app/electric-imp/id547133856) or [Android](https://play.google.com/store/apps/details?id=com.electricimp.electricimp))
  - A [Salesforce developer account](https://developer.salesforce.com/signup)

### Hardware
  - An Electric Imp  [impExplorer<sup>TM</sup> kit](https://store.electricimp.com/collections/featured-products/products/impexplorer-developer-kit-for-salesforce-trailhead?variant=31720746706)

And if you want to install the board into a fridge:

  - 3 AA Batteries

## Getting Started

### Step 2: Setup the Electric Imp hardware

First we will need to assemble the impExplorer Kit.  The kit comes with (1) the imp001 card, which has a WiFi radio and microcontroller which drives all the logic for the board and (2) the impExplorer Kit into which the card is plugged.  The impExplorer Kit provides a set of sensors and peripherals which are ready to use. This project will take readings from temperature, humidity and light sensors to determine the current state of your fridge.

#### Hardware Setup
 - Plug the imp001 card into the card slot on the impExplorer Kit
 - Power up your impExplorer Kit with the provided mini-B USB cable or the AA Batteries
 - The imp001 should now have power and be blinking amber/red

Assmbled it should look like this:

![Explorer Kit](http://i.imgur.com/6JssX74.png)

#### Electric Imp BlinkUp

Use the Electric Imp mobile app to BlinkUp your device

 - Log into your Electric Imp account
 - Enter your WiFi credentials
 - Follow the instructions in the app to [BlinkUp](https://electricimp.com/platform/blinkup/) your device
 - Make a note of the Device ID of your device (the app shows it after successfull blink up). You will need it to assign the device in the Electric Imp IDE.

 If you have any issues getting started with your Electric Imp account or device, see [the full getting started guide](https://electricimp.com/docs/gettingstarted/explorer/quickstartguide/).

### Step 3: Add Code for the Electric Imp

#### How Electric Imp's connectivity platform works

The Electric Imp IoT Connectivity Platform has two main components -- the impDevice<sup>TM</sup> and the impCloud<sup>TM</sup>.  The impDevice runs the device code, which in this use case consolidates the data gathered by the temperature/humidity/light sensors.  Each device is paired one-to-one with a "virtual twin" -- or, as we call it, an agent -- in the impCloud.  The device sends this data to its agent, which runs agent code. In this example the agent code forwards the data from the device to the Salesforce cloud.  Here's a broad overview of this flow:

<img src="http://i.imgur.com/VpZHzdS.jpg" width="600">

The Electric Imp IDE provides all the tools you need to write and deploy the software (to the device and agent) that will control your imp-enabled connected product. The IDE runs in a desktop web browser and communicates between the device and cloud solutions.

 If you'd like a quick overview of the IDE features please visit the Electric Imp [Dev Center](https://electricimp.com/docs/ideuserguide/).

#### Electric Imp IDE / Code

 - In your favorite web browser log into the [Electric Imp IDE](https://preview-impcentral.electricimp.com/login)
 - Click **Create a Product** button
![Empty IDE](https://imgur.com/I0oMuaX.png)
 - In the pop up enter Product name (e.g. **SmartFridge**) and Application Workspace name (e.g. **SmartFridge**) and click **Create** button
![Create Product](https://imgur.com/hFKYX4C.png)
 - Copy and Paste the [agent code](./SmartRefrigerator_ExplorerKit_Salesforce.agent.nut) from github into the left side agent window
 - Copy and Paste the [device code](./SmartRefrigerator_ExplorerKit_Salesforce.device.nut) from github into the right side device window
 - Click **Assign devices** link
![Empty IDE code](https://imgur.com/Jjl4fKx.png)
 - In the pop up choose your device and click **Assign**
![Assign device](https://imgur.com/8VjrXqB.png)

 - Between the code and the logs windows in the IDE you can find agent url of your device. It will look similar to this ```"https://agent.electricimp.com/szPc0sLfAqlu"``` BlinkUp app showed the same url after successfull blink up.
 - Make a note of the agent url. You will need it when creating your connected app in Salesforce.
 ![IDE code windows](https://imgur.com/x5fGsNP.png)
- Do not close IDE page.

### Step 4: Create a Salesforce Connected App

- Log into [Salesforce](https://login.salesforce.com/)

#### Creating a Connected App in Salesforce

- Click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **App Manager** into the Quick Find box and then select **AppManager**.
![Salesforce QuickFind App Manager](https://imgur.com/NQXBMdM.png)
- Click **New Connected App**.
- In the **New Connected App** form fill in:
  - Basic Information:
    - Connect App Name: **Electric Imp SmartFridge**
    - API Name should automatically becomes **Electric_Imp_SmartFridge**
    - Contact Email: enter your email address
  - API (Enable OAuth Settings):
    - Check the **Enable OAuth Settings** Box
    - **Callback URL**: enter agent url of your device (copy it from the Electric Imp IDE - see the previous step)
    - **Selected OAuth Scopes**:
      - Select **Access and manage your data (api)**
      - Click **Add**
![Salesforce Connected App](https://imgur.com/YcRqCXy.png)
  - Click **Save**
  - Click **Continue**
- You will be redirected to your Connected App's page
  - Make a note of your **Consumer Key** (you will need to enter it into your agent code)
  - Click **Click to reveal** next to the Consumer Secret field
  - Make note of your **Consumer Secret** (you will need to enter it into your agent code)
![Salesforce Keys](https://imgur.com/XpJXq1I.png)
- Do not close Salesforce page.

#### Adding API keys to your Electric Imp Code

- Return back to the Electric Imp IDE page.
- Find the *SALESFORCE CONSTANTS* section at the end of the agent code and enter your **Consumer Key** and **Consumer Secret** (copy them from the Salesforce Connected App's page).
![IDE with code](https://imgur.com/DKc0Kyr.png)
- Do not close IDE page.

### Step 5: Create a Custom Object in Salesforce

#### Creating a Custom Object in Salesforce

You will need to create a custom object with fields that correspond to each key in the reading table (??? totally not clear). There is the step by step instruction for creating a Custom Object:

- Return back to the Salesforce page.
- Click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Click on **Object Manager** tab next to **Home**.
![Object Manager](https://imgur.com/bJhA9xk.png)
- Click on **Create** drop-down and then select **Custom Object**.
![Custom Object Create](https://imgur.com/0uYtuPk.png)
- In the **New Custom Object** form fill in:
    - Custom Object Information
      - Label: **SmartFridge**
      - Plural Label: **SmartFridges**
      - Object Name: **SmartFridge**
    - Enter Record Name Label and Format
      - Record Name: **Reading Id** (replace the default **SmartFridge Name**)
      - Data Type: **Auto Number**
      - Display Format: **R-{0000}**
      - Starting Number: **1**
![Custom Object Info](https://imgur.com/w4J67Jq.png)
    - Click **Save**
- On the **SmartFridge** Custom Object page, check that **API Name** is **SmartFridge__c**
![Custom Object Api Name](https://imgur.com/y5spRHY.png)

#### Adding Custom Fields to the SmartFridge Object
After creating the **SmartFridge** custom object, let's add custom fields to track all the information you’ll collect from your fridge.

- Select the **Fields & Relationships** section from the left navigation.
  - Click **New**.
- Create a field for the temperature:
  - **Step 1. Choose the field type** - choose Data Type: **Number**
  - Click **Next**
  - **Step 2. Enter the details**:
    - Field Label: **temperature**
    - Length: **4**
    - Decimal Places: **2**
    - Field Name: **temperature**
![Temperature Field](https://imgur.com/40XLV2B.png)
  - Click **Next**, **Next**, and then **Save & New**.
- Create a field for the humidity (similar as for the temperature):
  - **Step 1. Choose the field type** - choose Data Type: **Number**
  - Click **Next**
  - **Step 2. Enter the details**:
    - Field Label: **humidity**
    - Length: **4**
    - Decimal Places: **2**
    - Field Name: **humidity**
  - Click **Next**, **Next**, and then **Save & New**.
- Create a field for the door status:
  - **Step 1. Choose the field type** - choose Data Type: **Picklist**
  - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **door**
    - Values: Select **Enter values, with each value separated by a new line**
    - Enter **Open** and **Closed** so that they are on separate lines.
    - Field Name: **door**
![Door Field](https://imgur.com/XqAEQ10.png)
  - Click **Next**, **Next**, and then **Save & New**.
- Create a field for the timestamp:
  - **Step 1. Choose the field type** - choose Data Type: **Date/Time**
  - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **ts**
    - Field Name: **ts**
  - Click **Next**, **Next**, and then **Save & New**.
- Create a field for the device’s ID:
  - **Step 1. Choose the field type** - choose Data Type: **Text**
  - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **deviceId**
    - Length: **16**
    - Field Name: **deviceId**
    - Check **Always require a value in this field in order to save a record**
    - Check **Set this field as the unique record identifier from an external system**
![DeviceId Field](https://imgur.com/WApbOvX.png)
  - Click **Next**, **Next**, and then **Save**.

- Check that SmartFridge **Fields & Relationships** looks like this:
![SmartFridge Fields](https://imgur.com/10aY29u.png)

### Step 6: Create a Custom Case Field in Salesforce

We want the cases opened to contain the Device ID for our refrigerator.  To do this we need to create a custom field for our Salesforce case.  Here are the step by step instructions for creating a Custom Case Field:

1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Click on **Object Manager** tab next to **Home**.
![Object Manager](https://imgur.com/bJhA9xk.png)
3. Click the **Case** object.
4. Select the **Fields & Relationships** section and click the **New** button.
![New Fields and Relationships](https://imgur.com/qCZzI3r.png)

5. In the **New Custom Field** form fill in:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **deviceId**
  - Length: **16**
  - Field Name: **deviceId**
  - Check **External ID**
  - Click **Next**, **Next** and then **Save**
![Related Fridge](https://imgur.com/ZN1ekyE.png)
6. Select the **Fields & Relationships** section and find your newly created **deviceId** custom field. Make sure the **Field Name** is **deviceId__c**.
![Case Fields](https://imgur.com/3i8uHjK.png)

### Step 7: Create Platform Events in Salesforce

#### Creating Platform Events in Salesforce

You will need to create Platform Event that correspond to ElectricImp SmartFridge data readings. Here are the step by step instructions for creating Platform Event:

To create **Platform Event** for SmartFridge data readings:
1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Enter **Platform Events** into the Quick Find box and then select **Data > Platform Events**.
![Salesforce QuickFind Platform Events](https://imgur.com/CXCuSr1.png)
3. Click **New Platform Event**.
4. In the **New Platform Event** form fill in:
  - Field Label: **Smart Fridge Reading**
  - Plural Label: **Smart Fridge Readings**
  - Object Name: **Smart_Fridge_Reading**
  - Click **Save**
![New Smart Fridge Reading Event](https://imgur.com/4otU27s.png)
5. You will be redirected to the **Smart Fridge Reading** Platform Event page. Now you need to create Platform Event fields that correspond to your fridge readings. In the **Custom Fields & Relationships** section click **New**.
![Smart Fridge Reading Event New Field](https://imgur.com/gbmXQRK.png)
6. Create a field for temperature with the following settings:
  - Data Type: **Number**
  - Click **Next**
  - Field Label: **temperature**
  - Length: **4**
  - Decimal Places: **2**
  - Field Name: **temperature**
7. Click **Save**. In the **Custom Fields & Relationships** section click **New**.
8. Create a field for humidity with the following settings:
  - Data Type: **Number**
  - Click **Next**
  - Field Label: **humidity**
  - Length: **4**
  - Decimal Places: **2**
  - Field Name: **humidity**
9. Click **Save**. In the **Custom Fields & Relationships** section click **New**.
10. Create a field for the door status with the following settings:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **door**
  - Length: **10**
  - Field Name: **door**
11. Click **Save**. In the **Custom Fields & Relationships** section click **New**.
12. Create a field for a timestamp with the following settings:
  - Data Type: **Date/Time**
  - Click **Next**
  - Field Label: **ts**
  - Field Name: **ts**
13. Click **Save**. In the **Custom Fields & Relationships** section click **New**.
14. Create a field for the device’s ID with the following settings:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **deviceId**
  - Length: **16**
  - Field Name: **deviceId**
  - Check **Required**
15. Click **Save**.
16. Confirm that **Smart Fridge Reading** **API Name** is **Smart_Fridge_Reading__e** and **Fields & Relationships** looks like this:
![Smart Fridge Reading Event Details](https://imgur.com/4BQA37p.png)

### Step 8: Create Context in Salesforce

1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Enter **Contexts** into the Quick Find box and then select **Feature Settings > IoT Explorer > Contexts**.
![Contexts](https://imgur.com/9Sp7hpy.png)
3. Click **New Context**.
4. In the New Context form fill in:
  - Context Name: **Smart Fridge Context**
  - Key Type: **String**
  - Click **Save**
5. You will be redirected to the **Smart Fridge Context** page. In the **Platform Events** section click **Add**.
![Context Add Platform Event](https://imgur.com/ySmNGqq.png)
6. In the Add Platform Event form fill in:
  - Context: **Smart Fridge Context**
  - Platform Event: **Smart Fridge Reading**
  - Key: **deviceId**
  - Click **Save**

### Step 9: Create Orchestrations in Salesforce

You will need to create an Orchestration that processes Platform Events and produces Cases when
1. the refrigerator door is opened for more than 30 seconds (3 data readings in a row), or 
2. the temperature is over 11°C, or 
3. the relative humidity is over 70%.

If the reason of a Case isn't eliminated, the Case will be produced repeatedly every 30 minutes.

Here are the step by step instructions for creating Orchestration:

#### Creating Orchestration

1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Enter **Orchestrations** into the Quick Find box and then select **Feature Settings > IoT Explorer > Orchestrations**.
![Orchestrations](https://imgur.com/8i2qDU9.png)
3. Click **New Orchestration**.
4. In the New Orchestration pop up fill in:
  - Name: **Smart Fridge Orchestration**
  - Context: **Smart Fridge Context**
  - Click **Create**
![New Orchestration](https://imgur.com/gWMgKur.png)

#### Creating Orchestration Variables

1. Click on **VARIABLES** tab. Now you need to create temperature, humidity and door open thresholds and additional variable to produce door open Cases. Click **Add Variable**.
![Variables](https://imgur.com/75kHG00.png)
2. Create a varable for temperature threshold with the following settings:
  - Name: **TEMPERATURE_THRESHOLD**
  - Data Type: **Number**
  - Initial Value: **11**
3. Click **Add Variable**.
4. Create a varable for humidity threshold with the following settings:
  - Name: **HUMIDITY_THRESHOLD**
  - Data Type: **Number**
  - Initial Value: **70**
5. Click **Add Variable**.
6. Create a varable for door open counter limit with the following settings:
  - Name: **DOOR_OPEN_LIMIT**
  - Data Type: **Number**
  - Initial Value: **3**
7. Click **Add Variable**.
8. Create a varable for door open counter with the following settings:
  - Name: **door_open_counter**
  - Data Type: **Number**
  - Event Type: **Smart_Fridge_Reading__e**
  - IF: `Smart_Fridge_Reading__e.door__c = "open"`
  - Value: **Count 1 min**
  - Initial Value: **0**
9. Make sure your Orchestration variables looks like this:
![Orchestration variables](https://imgur.com/FiSs6SB.png)

#### Creating Orchestration Rules

##### Configuring Default Rule

1. Click on **RULES** tab.
2. In the **Default** state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
![Default state](https://imgur.com/em5GdAG.png)
3. In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
![Default state action](https://imgur.com/VvSpbWv.png)
4. In the **New Salesforce Output Action** pop up choose: 
  - Object: **SmartFridge**
  - Action Type: **Create**
  - Click **Next**
![Create SmartFridge action](https://imgur.com/IDym7Zl.png)
5. In the **Assign values to record fields** table:
  - Enter **deviceId__c** value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **temperature__c** in **Select field**
  - Enter **temperature__c** value: `Smart_Fridge_Reading__e.temperature__c`
  - Click **Add Field**
  - Choose **humidity__c** in **Select field**
  - Enter **humidity__c** value: `Smart_Fridge_Reading__e.humidity__c`
  - Click **Add Field**
  - Choose **humidity__c** in **Select field**
  - Enter **humidity__c** value: `Smart_Fridge_Reading__e.humidity__c`
  - Click **Add Field**
  - Choose **door__c** in **Select field**
  - Enter **door__c** value: `Smart_Fridge_Reading__e.door__c`
  - Click **Add Field**
  - Choose **ts__c** in **Select field**
  - Enter **ts__c** value: `Smart_Fridge_Reading__e.ts__c`
6. Confirm that **Assign values to record fields** table looks like this:
![Create SmartFridge fields](https://imgur.com/We2WlA2.png)
7. In **Action Name** field enter **Create SmartFridge Reading**
8. Click **Finish**

##### Adding Door Open Rule

1. Click **Add State**
![Add State](https://imgur.com/wh9fOxX.png)
2. Enter **Door Open** in new state name.
3. In the **Door Open** state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
4. In the **Condition** column enter `Smart_Fridge_Reading__e.door__c = "closed"`
5. In the **Actions** column click **Add an action** and choose **ORCHESTRATION ACTIONS > Reset Variable**. Then choose **door_open_counter**.
6. In the **Transition** column choose **Default**
![Door Open state](https://imgur.com/L2QnSK9.png)
7. Click **Add rule** in the **Door Open** State menu.
![Door Open add rule](https://imgur.com/ENZu8a5.png)
8. In the new state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
9. Click to **Condition** column and click **Add limit repeating the rule (optional)**.
![Condition Add limit](https://imgur.com/E4cZCL9.png)
10. Enter **1 time(s) per 30 minutes**.
![Door Open Condition](https://imgur.com/mZszuib.png)
11. In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
12. In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
  - Click **Next**
![Door Open Case create](https://imgur.com/tFjtEzE.png)
13. In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Refrigerator Door Open"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"door has been opened for 30 seconds"`
14. Confirm that **Assign values to record fields** table looks like this:
![Door Open Case fields](https://imgur.com/Bdq4IiU.png)
15. In **Action Name** field enter **Create Door Open Case**
16. Click **Finish**
17. Click **Add rule** in the **Default** State menu.
![Default State add rule](https://imgur.com/ATzWdwt.png)
18. In the new state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
19. In the **Condition** column enter `door_open_counter >= DOOR_OPEN_LIMIT`.
20. In the **Transition** column choose **Door Open**.
![Default To Door Open](https://imgur.com/wdl2GJl.png)

##### Adding Temperature Over Threshold Rule

1. Click **Add State**.
2. Enter **Temperature Over Threshold** in new state name.
3. In the **Temperature Over Threshold** state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
4. In the **Condition** column enter `Smart_Fridge_Reading__e.temperature__c < TEMPERATURE_THRESHOLD`.
5. In the **Transition** column choose **Default**.
![Temperature State](https://imgur.com/EsgoFdZ.png)
6. Click **Add rule** in the **Temperature Over Threshold** State menu.
7. In the new state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
8. Click to **Condition** column and click **Add limit repeating the rule (optional)**.
9. Enter **1 time(s) per 30 minutes**.
![Temperature State Condition](https://imgur.com/pyiAwOw.png)
10. In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
11. In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
  - Click **Next**
12. In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Temperature Over Threshold"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"current temperature " + TEXT(Smart_Fridge_Reading__e.temperature__c) + " is over threshold"`
13. Confirm that **Assign values to record fields** table looks like this:
![Temperature State Case fields](https://imgur.com/bRzaxmx.png)
14. In **Action Name** field enter **Create Temperature Case**
15. Click **Finish**
16. Click **Add rule** in the **Default** State menu.
17. In the new state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
18. In the **Condition** column enter `Smart_Fridge_Reading__e.temperature__c >= TEMPERATURE_THRESHOLD`.
19. In the **Transition** column choose **Temperature Over Threshold**.
![Default To Temperature transition](https://imgur.com/mNvN8Zm.png)

##### Adding Humidity Over Threshold Rule

1. Click **Add State**.
2. Enter **Humidity Over Threshold** in new state name.
3. In the **Humidity Over Threshold** state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
4. In the **Condition** column enter `Smart_Fridge_Reading__e.humidity__c < HUMIDITY_THRESHOLD`.
5. In the **Transition** column choose **Default**.
![Humidity State](https://imgur.com/7X14w3U.png)
6. Click **Add rule** in the **Humidity Over Threshold** State menu.
7. In the new state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
8. Click to **Condition** column and click **Add limit repeating the rule (optional)**.
9. Enter **1 time(s) per 30 minutes**.
![Humidity State Condition](https://imgur.com/pl7KBcT.png)
10. In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
11. In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
  - Click **Next**
12. In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Humidity Over Threshold"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"current humidity " + TEXT(Smart_Fridge_Reading__e.humidity__c) + " is over threshold"`
13. Confirm that **Assign values to record fields** table looks like this:
![Humidity Case fields](https://imgur.com/ZGnHfcm.png)
14. In **Action Name** field enter **Create Humidity Case**
15. Click **Finish**
16. Click **Add rule** in the **Default** State menu.
17. In the new state **When** column click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
18. In the **Condition** column enter `Smart_Fridge_Reading__e.humidity__c >= HUMIDITY_THRESHOLD`.
19. In the **Transition** column choose **Humidity Over Threshold**.
![Default to Humidity transition](https://imgur.com/DpYCVwH.png)

##### Orchestration Activation

1. Click on **STATES** tab. Confirm that your States diagram looks like this:
![States](https://imgur.com/Noz1EXu.png)
2. Click on **Activate** button. In the pop up click **Activate** again.
![Activate](https://imgur.com/H7zBYSy.png)

### Step 10: Build and Run the Electric Imp Application

These examples use OAuth 2.0 for authentication, so the agent has been set up as a web server to handle the log in.
Go to the Electric Imp IDE and select your device from the sidebar for the final setup steps.

- Hit **Build and Run** to save and launch the code
- Click on the agent url to launch the log in page
- Log into Salesforce

![IDE Screenshot](https://imgur.com/6rm6FBf.png)

Your App should now be up and running.  You can monitor the device logs in the IDE, or log into Salesforce web portal to see updates there.

### Step 11: Install Device in Refrigerator

Open your refrigerator and place the impExplorer Kit on a shelf in your refrigerator door.

![Imp In Fridge](http://i.imgur.com/z5llZBg.png)

If you don't have a fridge handy for this scenario, you can test the door being open by keeping the imp in a lit room.  A door open for thirty seconds should register a case.

### Step 12: Monitor the data in Salesforce1

Now that you have connected your imp to Salesforce, it might be handy to see that data on a mobile device.  Using Salesforce1, it is easy to keep track of your Smart Fridge on the go.

#### Create a Custom Object Tab

First, let's give the custom object a tab so that Salesforce1 can add it to the left navigation.

1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Enter **Tabs** into the Quick Find box and then select **User Interface > Tabs**.
3. Under **Custom Object Tabs**, click **New**
4. Choose **SmartFridge** from the Object dropdown
5. Choose **Thermometer** as the Tab Style  
![Custom Object](http://i.imgur.com/eXyOmd6.png)
6. Click **Next**, **Next**, and then **Save**

#### Open Salesforce1 in Chrome

You can access the Salesforce1 mobile app in three ways:

- As a downloadable mobile app (Salesforce1) that you install on your phone from the Apple AppStore or Google Play
- By navigating to `login.salesforce.com` using a mobile browser
- By using the Chrome Developer Tools

For this step, we'll use the last option. First ensure that Salesforce1 is available through a desktop browser and is enabled for your user:

1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Enter **Salesforce1** into the Quick Find box and then select **Apps > Mobili Apps > Salesforce1 > Salesforce1 Settings**.
3. Ensure the Enable the Salesforce1 mobile browser app is checked.  
![App settings checkbox](http://i.imgur.com/Tigi9eK.png)
4. Enter **Users** into into the Quick Find box and select **Users > Users**.
5. Click **Edit** next to your username.
6. Ensure that Salesforce1 User is checked. If not, check it and click **Save**.  
![Salesforce1 User checkbox](http://i.imgur.com/svdRddT.png)

Next we’ll emulate the Salesforce1 Mobile App in the Chrome web browser:

1. Open a new tab in your Chrome browser and open the Developer Tools by clicking *View* | *Developer* | *Developer Tools*
2. Click the Toggle Device Mode button to simulate your browser as a mobile device.  
![Chrome Tools Mobile Simulator](http://i.imgur.com/hzb2F0N.png)
3. To simulate the Salesforce1 app in your browser, copy and paste in the URL from the previous tab. Remove the part of the URL immediately after `lightning.force.com`. For example:  
![URL original](https://imgur.com/UZYqV21.png)
![URL removed](https://imgur.com/jPYa1t7.png)
4. Append `/one/one.app` to the end of the URL after salesforce.com to start the Salesforce1 Application simulator. For example:  
![URL one/one.app](https://imgur.com/V0Deg1d.png)
5. If the display is too small, change the size to 100%.  
![URL one/one.app](http://i.imgur.com/BvmL50q.png)
6. Click the three white bars in the upper left to open the left navigation
7. Under the "Recent" section, scroll down and click *More*  
![Menu](http://i.imgur.com/xv2YL52.png)
8. You will see "SmartFridges" somewhere on the list. Click *SmartFridges*  
![Menu](http://i.imgur.com/GHcC0gG.png)
9. Select a record to view the details of the reading.  
![Reading record](https://imgur.com/d3N5N7F.png)

### Step 13: Monitor Orchestration States transitions and Cases

Let’s try out Orchestration States transitions and Cases.

1. Log into Salesforce, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
2. Enter **Orchestrations** into the Quick Find box and then select **Feature Settings > IoT Explorer > Orchestrations**.
![Orchestrations](https://imgur.com/8i2qDU9.png)
3. Click on **Smart Fridge Orchestration**. Then click on **TRAFFIC** tab. If your ElectricImp are in a fridge, you can see that your device is in **Default** normal state.
![Default state](https://imgur.com/XQ0DyYd.png)
4. Keep the fridge door open for over 30 seconds (or just place the imp to a lit room).
5. On the **TRAFFIC** tab check that your device got into **Door Open** state.
![Door Open state](https://imgur.com/h2Hdeg5.png)
6. Move the imp to a warm dark place.
6. On the **TRAFFIC** tab check that your device got into **Temperature Over Threshold** state.
![Temperature state](https://imgur.com/z7uB2CD.png)
7. Open Salesforce1 mobile app as described in the previous Step.
8. Click the three white bars in the upper left to open the left navigation.
9. Under the "Recent" section, click **Cases**.  
![Cases menu](https://imgur.com/fGVaet7.png)
10. You will see the registered Cases.  
![Cases](https://imgur.com/WDGJrUp.png)
