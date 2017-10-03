# Salesforce Smart Refrigerator

The following Trailhead project will use the Electric Imp platform to connect and monitor a refrigerator and a Salesforce *Connected App* to track the current temperature and humidity in the fridge.

To track the current temperature and humidity we will create a Salesforce *Custom Object* and put readings data to it every 15 seconds using Salesforce *Platform Events*.

This example will also *open a Case* in Salesforce using *IoT Explorer Orchestration* if: 
1. the refrigerator door is opened for more than a predefined threshold, or 
2. the temperature is over a predefined threshold, or 
3. the relative humidity is over a predefined threshold.

All thresholds are defined later, at the step when you setup *IoT Explorer Orchestration*.

### Step 1: Intro - What you need

#### General
 - Your WIFI *network name* and *password*
 - A smartphone (iOS or Android)
 - A computer with a web browser

#### Accounts
  - An [Electric Imp developer account](https://preview-impcentral.electricimp.com/login)
  - The Electric Imp BlinkUp<sup>TM</sup> app ([iOS](https://itunes.apple.com/us/app/electric-imp/id547133856) or [Android](https://play.google.com/store/apps/details?id=com.electricimp.electricimp))
  - A [Salesforce developer account](https://developer.salesforce.com/signup)

#### Hardware
  - An Electric Imp  [impExplorer<sup>TM</sup> kit](https://store.electricimp.com/collections/featured-products/products/impexplorer-developer-kit-for-salesforce-trailhead?variant=31720746706)

And if you want to install the board into a fridge:

  - 3 AA Batteries

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
 - Make a note of the Device ID of your device (the app shows it after successful blink up). You will need it to assign the device in the Electric Imp IDE.

 If you have any issues getting started with your Electric Imp account or device, see [the full getting started guide](https://electricimp.com/docs/gettingstarted/explorer/quickstartguide/).

### Electric Imp's Connectivity Description

The Electric Imp IoT Connectivity Platform has two main components -- the impDevice<sup>TM</sup> and the impCloud<sup>TM</sup>.  The impDevice runs the device code, which in this use case consolidates the data gathered by the temperature/humidity/light sensors.  Each device is paired one-to-one with a "virtual twin" -- or, as we call it, an agent -- in the impCloud.  The device sends this data to its agent, which runs agent code. In this example the agent code forwards the data from the device to the Salesforce cloud as a Platform Event.  Here's a broad overview of this flow:

<img src="http://i.imgur.com/VpZHzdS.jpg" width="600">

The Electric Imp IDE provides all the tools you need to write and deploy the software (to the device and agent) that will control your imp-enabled connected product. The IDE runs in a desktop web browser and communicates between the device and cloud solutions.

 If you'd like a quick overview of the IDE features please visit the Electric Imp [Dev Center](https://electricimp.com/docs/ideuserguide/).

### Step 3: Add Code for the Electric Imp

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

 - Between the code and the logs windows in the IDE you can find agent url of your device. It will look similar to this ```"https://agent.electricimp.com/szPc0sLfAqlu"``` BlinkUp app showed the same url after successful blink up.
 - Make a note of the agent url. You will need it when creating your connected app in Salesforce.
 ![IDE code windows](https://imgur.com/x5fGsNP.png)
- Do not close IDE page.

### Salesforce IoT Explorer Description

??? TODO - add some links + what we are going to creat below...

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
- Find the *SALESFORCE CONSTANTS* section at the end of the agent code and initialize your **CONSUMER_KEY** and **CONSUMER_SECRET** constants (copy their values from the Salesforce Connected App's page).
![IDE with code](https://imgur.com/DKc0Kyr.png)
- Do not close IDE page.

### Step 5: Create a Custom Object in Salesforce

#### Creating a Custom Object in Salesforce

??? You will need to create a custom object with fields that correspond to each key in the reading table.

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
- On the **SmartFridge** Custom Object page, make sure that **API Name** is **SmartFridge__c**
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

- Make sure that SmartFridge **Fields & Relationships** looks like this:
![SmartFridge Fields](https://imgur.com/10aY29u.png)

### Step 6: Create a Custom Case Field in Salesforce

??? We want the cases opened to contain the Device ID for our refrigerator. To do this you need to create a custom field for your Salesforce case.

- On the Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Click on **Object Manager** tab next to **Home**.
![Object Manager](https://imgur.com/bJhA9xk.png)
- Click the **Case** object.
- Select the **Fields & Relationships** section and click the **New** button.
![New Fields and Relationships](https://imgur.com/qCZzI3r.png)

- In the **New Custom Field** form:
  - **Step 1. Choose the field type** - choose Data Type: **Text**
  - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **deviceId**
    - Length: **16**
    - Field Name: **deviceId**
    - Check **Set this field as the unique record identifier from an external system**
![Related Fridge](https://imgur.com/ZN1ekyE.png)
  - Click **Next**, **Next** and then **Save**
- Select the **Fields & Relationships** section and find your newly created **deviceId** custom field.
- Make sure the **Field Name** is **deviceId__c**.
![Case Fields](https://imgur.com/3i8uHjK.png)

### Step 7: Create Platform Events in Salesforce

#### Creating Platform Events in Salesforce

??? You need to create **Platform Event** that correspond to ElectricImp SmartFridge data readings.
??? Mandatory names here - these fields are used by the imp app?

- On the Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Platform Events** into the Quick Find box and then select **Data > Platform Events**.
![Salesforce QuickFind Platform Events](https://imgur.com/CXCuSr1.png)
- Click **New Platform Event**.
- In the **New Platform Event** form fill in:
  - Field Label: **Smart Fridge Reading**
  - Plural Label: **Smart Fridge Readings**
  - Object Name: **Smart_Fridge_Reading**
![New Smart Fridge Reading Event](https://imgur.com/4otU27s.png)
  - Click **Save**
- You will be redirected to the **Smart Fridge Reading** Platform Event page. Now you need to create Platform Event fields that correspond to your fridge readings.
- In the **Custom Fields & Relationships** section click **New**.
![Smart Fridge Reading Event New Field](https://imgur.com/gbmXQRK.png)
- Create a field for the temperature:
  - Data Type: **Number**
  - Click **Next**
  - Field Label: **temperature**
  - Length: **4**
  - Decimal Places: **2**
  - Field Name: **temperature**
- Click **Save**.
- In the **Custom Fields & Relationships** section click **New**.
- Create a field for the humidity:
  - Data Type: **Number**
  - Click **Next**
  - Field Label: **humidity**
  - Length: **4**
  - Decimal Places: **2**
  - Field Name: **humidity**
- Click **Save**.
- In the **Custom Fields & Relationships** section click **New**.
- Create a field for the door status:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **door**
  - Length: **10**
  - Field Name: **door**
- Click **Save**.
- In the **Custom Fields & Relationships** section click **New**.
- Create a field for the timestamp:
  - Data Type: **Date/Time**
  - Click **Next**
  - Field Label: **ts**
  - Field Name: **ts**
- Click **Save**
- In the **Custom Fields & Relationships** section click **New**.
- Create a field for the device’s ID:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **deviceId**
  - Length: **16**
  - Field Name: **deviceId**
  - Check **Always require a value in this field in order to save a record**
- Click **Save**.
- Make sure that **Smart Fridge Reading** **API Name** is **Smart_Fridge_Reading__e** and **Custom Fields & Relationships** looks like this:
![Smart Fridge Reading Event Details](https://imgur.com/4BQA37p.png)
- Return back to the Electric Imp IDE page.
- Find the *SALESFORCE CONSTANTS* section at the end of the agent code and make sure your **READING_EVENT_NAME** constant value is **Smart_Fridge_Reading__e** (i.e. the same as **Smart Fridge Reading** **API Name** value of the just created **Platform Event**).
![IDE with code](https://imgur.com/DKc0Kyr.png)
- Do not close IDE page.

### Step 8: Create Context in Salesforce

- On the Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Contexts** into the Quick Find box and then select **Feature Settings > IoT Explorer > Contexts**.
![Contexts](https://imgur.com/9Sp7hpy.png)
- Click **New Context**.
- In the **New Context** form fill in:
  - Context Name: **Smart Fridge Context**
  - Key Type: **String**
  - Click **Save**
- You will be redirected to the **Smart Fridge Context** page.
- In the **Platform Events** section click **Add**.
![Context Add Platform Event](https://imgur.com/ySmNGqq.png)
- In the **Add Platform Event** form fill in:
  - Context: **Smart Fridge Context**
  - Platform Event: choose **Smart Fridge Reading** Platform Event you created early
  - Key: choose **deviceId**
  - Click **Save**

### Step 9: Create Orchestration in Salesforce

This example shows how to create an **Orchestration** that processes **Platform Events** and produces **Cases** when
1. the refrigerator door is opened for more than 30 seconds (3 data readings in a row ???), or 
2. the temperature is over 11°C, or
3. the relative humidity is over 70%.

If the reason of a **Case** is not eliminated, the **Case** will be produced repeatedly every 30 minutes.

You may setup other thresholds and/or another repeat period.

??? - maybe suggest by default smaller thresholds/period? - 20 sec, 8°C, 10 min ?

#### Creating Orchestration

- On the Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Orchestrations** into the Quick Find box and then select **Feature Settings > IoT Explorer > Orchestrations**.
![Orchestrations](https://imgur.com/8i2qDU9.png)
- Click **New Orchestration**.
- In the **New Orchestration** pop up fill in:
  - Name: **Smart Fridge Orchestration**
  - Context: choose **Smart Fridge Context** you created early
![New Orchestration](https://imgur.com/gWMgKur.png)
  - Click **Create**
  - You will be redirected to the **Smart Fridge Orchestration** page.
  
#### Creating Orchestration Variables

- Click on **VARIABLES** tab. Now you need to create temperature, humidity and door open thresholds and additional variable to produce door open Cases. (??? explain more ?)
- Click **Add Variable**.
![Variables](https://imgur.com/75kHG00.png)
- Create a varable for the temperature threshold:
  - Name: **TEMPERATURE_THRESHOLD**
  - Data Type: **Number**
  - Initial Value: **11** (for 11°C)
- Click **Add Variable**.
- Create a varable for the humidity threshold:
  - Name: **HUMIDITY_THRESHOLD**
  - Data Type: **Number**
  - Initial Value: **70** (for 70%)
- Click **Add Variable**.
- Create a varable for the door open counter limit:
  - Name: **DOOR_OPEN_LIMIT**
  - Data Type: **Number**
  - Initial Value: **3** (???)
- Click **Add Variable**.
- Create a varable for the door open counter:
  - Name: **door_open_counter**
  - Data Type: **Number**
  - Event Type: **Smart_Fridge_Reading__e** (Platform Event you create early)
  - IF: `Smart_Fridge_Reading__e.door__c = "open"` (???)
  - Value: **Count 1 min** (???)
  - Initial Value: **0**
- Make sure your Orchestration variables looks like this:
![Orchestration variables](https://imgur.com/FiSs6SB.png)

#### Creating Orchestration Rules

##### Configuring Default Rule

- Click on **RULES** tab.
- In the **When** column of the **Default** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
![Default state](https://imgur.com/em5GdAG.png)
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
![Default state action](https://imgur.com/VvSpbWv.png)
- In the **New Salesforce Output Action** pop up choose: 
  - Object: Custom > **SmartFridge**
  - Action Type: **Create**
![Create SmartFridge action](https://imgur.com/IDym7Zl.png)
  - Click **Next**
- In the **Assign values to record fields** table:
  - Enter **deviceId__c** value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **temperature__c** in **Select field**
  - Enter **temperature__c** value: `Smart_Fridge_Reading__e.temperature__c`
  - Click **Add Field**
  - Choose **humidity__c** in **Select field**
  - Enter **humidity__c** value: `Smart_Fridge_Reading__e.humidity__c`
  - Click **Add Field**
  - Choose **door__c** in **Select field**
  - Enter **door__c** value: `Smart_Fridge_Reading__e.door__c`
  - Click **Add Field**
  - Choose **ts__c** in **Select field**
  - Enter **ts__c** value: `Smart_Fridge_Reading__e.ts__c`
- Make sure that **Assign values to record fields** table looks like this:
![Create SmartFridge fields](https://imgur.com/We2WlA2.png)
- In **Action Name** field enter **Create SmartFridge Reading**
- Click **Finish**

##### Adding Door Open Rule

- Click **Add State**
![Add State](https://imgur.com/wh9fOxX.png)
- Enter **Door Open** as the new state name.
- In the **When** column of the **Door Open** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- In the **Condition** column enter `Smart_Fridge_Reading__e.door__c = "closed"` (???)
- In the **Actions** column click **Add an action** and choose **ORCHESTRATION ACTIONS > Reset Variable**. As a variable choose **door_open_counter**.
- In the **Transition** column choose **Default**
![Door Open state](https://imgur.com/L2QnSK9.png)
- Click **Add rule** in the **Door Open** State menu.
![Door Open add rule](https://imgur.com/ENZu8a5.png)
- In the **When** column of the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- Click to **Condition** column and click **Add limit repeating the rule (optional)**.
![Condition Add limit](https://imgur.com/E4cZCL9.png)
- Enter **1 time(s) per 30 minutes**. (???)
![Door Open Condition](https://imgur.com/mZszuib.png)
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
- In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
![Door Open Case create](https://imgur.com/tFjtEzE.png)
  - Click **Next**
- In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Refrigerator Door Open"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"door has been opened for 30 seconds"` ??? for too long
- Make sure that **Assign values to record fields** table looks like this:
![Door Open Case fields](https://imgur.com/Bdq4IiU.png)
- In **Action Name** field enter **Create Door Open Case**
- Click **Finish**
- Click **Add rule** in the **Default** State menu.
![Default State add rule](https://imgur.com/ATzWdwt.png)
- In the **When** column of the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- In the **Condition** column enter `door_open_counter >= DOOR_OPEN_LIMIT` (???)
- In the **Transition** column choose **Door Open**.
![Default To Door Open](https://imgur.com/wdl2GJl.png)

##### Adding Temperature Over Threshold Rule

- Click **Add State**.
- Enter **Temperature Over Threshold** as the new state name.
- In the **When** column of the **Temperature Over Threshold** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- In the **Condition** column enter `Smart_Fridge_Reading__e.temperature__c < TEMPERATURE_THRESHOLD`
- In the **Transition** column choose **Default**.
![Temperature State](https://imgur.com/EsgoFdZ.png)
- Click **Add rule** in the **Temperature Over Threshold** state menu.
- In the **When** column of the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- Click to **Condition** column and click **Add limit repeating the rule (optional)**.
- Enter **1 time(s) per 30 minutes** (???)
![Temperature State Condition](https://imgur.com/pyiAwOw.png)
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
- In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
  - Click **Next**
- In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Temperature Over Threshold"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"current temperature " + TEXT(Smart_Fridge_Reading__e.temperature__c) + " is over threshold"`
- Make sure that **Assign values to record fields** table looks like this:
![Temperature State Case fields](https://imgur.com/bRzaxmx.png)
- In **Action Name** field enter **Create Temperature Case**
- Click **Finish**
- Click **Add rule** in the **Default** state menu.
- In the **When** column of the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- In the **Condition** column enter `Smart_Fridge_Reading__e.temperature__c >= TEMPERATURE_THRESHOLD`
- In the **Transition** column choose **Temperature Over Threshold**.
![Default To Temperature transition](https://imgur.com/mNvN8Zm.png)

##### Adding Humidity Over Threshold Rule

- Click **Add State**.
- Enter **Humidity Over Threshold** as the new state name.
- In the **When** column of the **Humidity Over Threshold** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- In the **Condition** column enter `Smart_Fridge_Reading__e.humidity__c < HUMIDITY_THRESHOLD`
- In the **Transition** column choose **Default**.
![Humidity State](https://imgur.com/7X14w3U.png)
- Click **Add rule** in the **Humidity Over Threshold** state menu.
- In the **When** column of the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- Click to **Condition** column and click **Add limit repeating the rule (optional)**.
- Enter **1 time(s) per 30 minutes**.
![Humidity State Condition](https://imgur.com/pl7KBcT.png)
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
- In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
  - Click **Next**
- In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Humidity Over Threshold"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"current humidity " + TEXT(Smart_Fridge_Reading__e.humidity__c) + " is over threshold"`
- Make sure that **Assign values to record fields** table looks like this:
![Humidity Case fields](https://imgur.com/ZGnHfcm.png)
- In **Action Name** field enter **Create Humidity Case**
- Click **Finish**
- Click **Add rule** in the **Default** state menu.
- In the **When** column of the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**.
- In the **Condition** column enter `Smart_Fridge_Reading__e.humidity__c >= HUMIDITY_THRESHOLD`
- In the **Transition** column choose **Humidity Over Threshold**.
![Default to Humidity transition](https://imgur.com/DpYCVwH.png)

##### Orchestration Activation

- Click on **STATES** tab. Make sure that your States diagram looks like this:
![States](https://imgur.com/Noz1EXu.png)
- Click on **Activate** button. In the pop up click **Activate**
![Activate](https://imgur.com/H7zBYSy.png)
- Do not close Salesforce page

### Step 10: Build and Run the Electric Imp Application

- Return back to the Electric Imp IDE page.
- Make sure your device is Online (powered on, connected to your WiFi, IDE shows the device is in **Online** state).
- Click **Build and Run** to build and launch the code.
- Look at the log window of the IDE to see the logs from your running application.
- If you see **\[Agent] 	ERROR: Not logged into Salesforce.** error logs, it means your application is not authorized to connect to Salesforce yet.
  - This example uses OAuth 2.0 for authentication. The IMP agent has been set up as a web server to handle the authentication procedure.
  - Click on the agent url in the IDE.
![IDE Screenshot](https://imgur.com/6rm6FBf.png)
  - You will be redirected to the login page.
  - Log into Salesforce on that page.
  - If login is successful the page should display **"Authentication complete - you may now close this window"**
  - Close that page and return to the IDE page.
- Make sure there are no more errors in the logs.
- Make sure there are periodic logs like this **\[Agent] 	Readings sent successfully**
- Your application is now up and running.

### Step 11: Install Device in Refrigerator

Open your refrigerator and place the impExplorer Kit on a shelf in your refrigerator door.

![Imp In Fridge](http://i.imgur.com/z5llZBg.png)

??? If you don't have a fridge handy for this scenario, you can test the door being open by keeping the imp in a lit room.  A door open for thirty seconds should register a case.

### Step 12: Monitor the data

You can see the data, which your device sends, using **Salesforce1** mobile application.

#### Create a Custom Object Tab

First, you need to create **SmartFridge** custom tab, so it will be accessible in the mobile application.

- On Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Tabs** into the Quick Find box and then select **User Interface > Tabs**.
- Under **Custom Object Tabs**, click **New**
- Choose **SmartFridge** from the Object dropdown
- Choose **Thermometer** as the Tab Style  
![Custom Object](http://i.imgur.com/eXyOmd6.png)
- Click **Next**, **Next**, and then **Save**

#### Check Salesforce1 is Enabled

Ensure that **Salesforce1** mobile application is available and enabled for you:

- On Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Salesforce1** into the Quick Find box and then select **Apps > Mobili Apps > Salesforce1 > Salesforce1 Settings**.
- Make sure the **Enable the Salesforce1 mobile browser app** is checked.  
![App settings checkbox](http://i.imgur.com/Tigi9eK.png)
- Enter **Users** into the Quick Find box and select **Users > Users**.
- Click **Edit** next to your username.
- Make sure that **Salesforce1 User** is checked. If not, check it and click **Save**.  
![Salesforce1 User checkbox](http://i.imgur.com/svdRddT.png)

#### Run Salesforce1 Application

You can access and run **Salesforce1** mobile application in three ways:

- As a downloadable mobile application (Salesforce1) that you install and run on your phone from the Apple AppStore or Google Play (it's the most easy and recommended way)
- By opening `login.salesforce.com` page in a browser on your phone
- By using the Chrome Developer Tools (described below)

#### Open Salesforce1 in Chrome Browser

Use this way if you want/need to run **Salesforce1** application from your PC, not from a mobile phone.

It is possible to emulate **Salesforce1** mobile application in the Chrome web browser:

- On Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**
- Copy the current opened URL into clipboard
- Open a new tab in your Chrome browser
- Open the Developer Tools by clicking *View* | *Developer* | *Developer Tools*
- Click the Toggle Device Mode button to simulate your browser as a mobile device.  
![Chrome Tools Mobile Simulator](http://i.imgur.com/hzb2F0N.png)
- Paste from clipboard the URL you copied before. Do not press Enter.
- Remove the part of the URL immediately after `lightning.force.com`. For example:  
![URL original](https://imgur.com/UZYqV21.png)
![URL removed](https://imgur.com/jPYa1t7.png)
- Append `/one/one.app` to the end of the URL after salesforce.com. For example:  
![URL one/one.app](https://imgur.com/V0Deg1d.png)
- Press Enter. **Salesforce1** application emulation will be started in the Chrome Browser.
- If the display is too small, change the size to 100%.  
![URL one/one.app](http://i.imgur.com/BvmL50q.png)
- Click the three white bars in the upper left to open the navigation panel
- Under the "Recent" section, scroll down and click *More*  
![Menu](http://i.imgur.com/xv2YL52.png)
- You will see "SmartFridges" somewhere on the list. Click *SmartFridges*  
![Menu](http://i.imgur.com/GHcC0gG.png)
- Select a record to view the details of the reading.  
![Reading record](https://imgur.com/d3N5N7F.png)

### Step 13: Monitor Orchestration State Transitions and Cases

Also, you can see transitions between states which you defined in **IoT Explorer Orchestration** as well as registered **Cases**.

- On Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**.
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Orchestrations** into the Quick Find box and then select **Feature Settings > IoT Explorer > Orchestrations**.
![Orchestrations](https://imgur.com/8i2qDU9.png)
- Click on **Smart Fridge Orchestration**.
- Click on **TRAFFIC** tab. 
- If your ElectricImp device is in a fridge, you can see that your device is in **Default** normal state.
![Default state](https://imgur.com/XQ0DyYd.png)
- Keep the fridge door open for over 30 seconds ??? (or just place the device to a lit room).
- On the **TRAFFIC** tab see that your device moved into **Door Open** state.
![Door Open state](https://imgur.com/h2Hdeg5.png)
- Move the imp to a warm dark place.
- On the **TRAFFIC** tab see that your device moved into **Temperature Over Threshold** state.
![Temperature state](https://imgur.com/z7uB2CD.png)
- Run **Salesforce1** mobile app as described in the previous Step.
- Click the three white bars in the upper left to open the navigation panel.
- Under the "Recent" section, click **Cases**.  
![Cases menu](https://imgur.com/fGVaet7.png)
- You will see the registered Cases.  
![Cases](https://imgur.com/WDGJrUp.png)
