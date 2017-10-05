# Salesforce Smart Refrigerator

This demo uses the Electric Imp Platform to connect and monitor a refrigerator and a Salesforce cloud to track the current temperature, humidity in the fridge, and whether the door is open.

The imp application reads data from sensors every 15 seconds -- temperature, humidity and light (that equates to the door status: open/bright, closed/dark) -- and sends them to the cloud using Salesforce Platform Events.

The Salesforce cloud stores the incoming data and opens a Case using IoT Explorer Orchestration if: 

1. The refrigerator door is opened longer than a predefined period, or 
2. The temperature rises above a predefined threshold, or 
3. The relative humidity rises above a predefined threshold.

All thresholds are defined later, at the step when you set up IoT Explorer Orchestration.

### Step 1: Intro -- What You Need

#### General

- Your WiFi *network name* (SSID) and *password*
- A smartphone (iOS or Android)
- A computer with a web browser

#### Accounts

- An [Electric Imp developer account](https://preview-impcentral.electricimp.com/login)
- The Electric Imp mobile app ([iOS](https://itunes.apple.com/us/app/electric-imp/id547133856) or [Android](https://play.google.com/store/apps/details?id=com.electricimp.electricimp))
- A [Salesforce developer account](https://developer.salesforce.com/signup)

#### Hardware

- An Electric Imp [impExplorer&trade; kit](https://store.electricimp.com/collections/featured-products/products/impexplorer-developer-kit-for-salesforce-trailhead?variant=31720746706)

And if you want to run the board from inside a fridge:

- 3 AA Batteries

### Step 2: Set up the Electric Imp Hardware

First we will need to assemble the impExplorer Kit. The kit comes with:

1. An imp001 card, which has a WiFi radio and a microcontroller that drives all the logic for the board
2. The impExplorer board into which the card is plugged.

The impExplorer Kit provides a set of sensors and peripherals which are ready to use. This project will take readings from temperature, humidity and light sensors to determine the current state of your fridge.

#### Hardware Setup

- Plug the imp001 card into the card slot on the impExplorer 
- Power up your impExplorer Kit with the provided mini-B USB cable or the AA Batteries
- The imp001 should now have power and be blinking amber (or red if it has been used before)

Assembled, it should look like this:

![Explorer Kit](http://i.imgur.com/6JssX74.png)

#### Electric Imp BlinkUp&trade;

Use the Electric Imp mobile app to BlinkUp your device

- Log into your Electric Imp account
- Tap ‘Configure a Device’
- Enter your WiFi credentials
- Follow the instructions in the app to activate your device
- Make a note of the Device ID of your device (the app shows it after successful BlinkUp). You will need this in Electric Imp’s impCentral&trade;.

If you have any issues getting started with your Electric Imp account or device, see [the full getting started guide](https://electricimp.com/docs/gettingstarted/explorer/quickstartguide/).

#### Electric Imp's Connectivity Description

The Electric Imp IoT Connectivity Platform has two main components: the device and the impCloud&trade;. The device runs the device code, which in this use case consolidates the data gathered by the temperature/humidity/light sensors. Each device is paired one-to-one with its own agent in the impCloud. The agent operates as the device’s front end to the Internet. In this example, the agent code forwards the data from the device to the Salesforce cloud as a Platform Event. Here's a broad overview of this flow:

<img src="http://i.imgur.com/VpZHzdS.jpg" width="600">

impCentral provides all the tools you need to write and deploy the software (to the device and to the agent) that will control your imp-enabled connected product. impCentral runs in a desktop web browser.

### Step 3: Enter Device and Agent Code

- In your favorite web browser log into the [impCentral](https://preview-impcentral.electricimp.com/login)
- Click the **Create a Product** button
![Empty IDE](https://imgur.com/I0oMuaX.png)
- In the pop up, enter a Product name (eg. **SmartFridge**), an Application Workspace name (eg. **SmartFridge**), and then click the **Create** button
![Create Product](https://imgur.com/hFKYX4C.png)
- Copy and Paste the [agent code](./SmartRefrigerator_ExplorerKit_Salesforce.agent.nut) from Github into the left side agent window
- Copy and Paste the [device code](./SmartRefrigerator_ExplorerKit_Salesforce.device.nut) from Github into the right side device window
- Click the **Assign Devices** link
![Empty IDE code](https://imgur.com/Jjl4fKx.png)
- In the pop up, choose your device and click **Assign**
![Assign device](https://imgur.com/8VjrXqB.png)
- Between the code and the logs windows in impCentral you can find agent URL of your device. It will look similar to this ```"https://agent.electricimp.com/szPc0sLfAqlu"```
- Make a note of the agent URL. You will need it when creating your connected app in Salesforce.
![IDE code windows](https://imgur.com/x5fGsNP.png)
- Do not close impCentral.

#### Salesforce IoT Explorer Description

The data received from the device may be processed, stored and analyzed by Salesforce cloud. This example demonstrates just some of the Salesforce cloud capabilities. It may be modified or extended for your needs.

In this example the following Salesforce entities are created:

- **Connected Application** (see Step 4). Needed to authenticate the imp application in the Salesforce cloud so that Platform Events which are sent by the imp application are accepted by Salesforce.
- **Custom Object** (see Step 5). Used to store the data received from the device so that the historical data can be monitored, for example using the Salesforce1 mobile app.
- **Platform Event** (see Step 6). Used to transfer the data from the device to the Salesforce cloud. A **Platform Event Trigger** inserts the received data into the Custom Object.
- **IoT Explorer Context** (see Step 7). Required to create IoT Explorer Orchestration.
- **Custom Case Field** (see Step 8). Opens customized **Cases** -- a standard **Case** object with an additional field, the device ID.
- **IoT Explorer Orchestration** (see Step 9). Defines a fridge state machine that reacts to incoming Platform Events and opens Cases.
- **Custom Object Tab** (see Step 12). Needed to make the Custom Object (with the stored data from the device) accessible by the Salesforce1 mobile app.

Only the Platform Event acts as an ‘interface’ between the imp application and the Salesforce cloud. The Platform Event’s fields must have the names and types mentioned in this example (see Step 6). If you change anything in the Platform Event definition, you will need to update the imp application’s agent source code. The name of the Platform Event is defined in the agent code as a constant, *READING_EVENT_NAME*.

All other entities listed above are fully independent of the imp application.

The steps below suggest entities and field names solely as examples. You may change them, as well as the logic of the example: the  set of entities, rules, Cases, etc.

### Step 4: Create a Salesforce Connected Application

This stage is used to authenticate the imp application in the Salesforce cloud.

- Log into [Salesforce](https://login.salesforce.com/).

#### Create a Connected App in Salesforce

- Click the **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **App Manager** into the Quick Find box and then select **AppManager**:
![Salesforce QuickFind App Manager](https://imgur.com/NQXBMdM.png)
- Click **New Connected App**.
- In the **New Connected App** form fill in:
  - Basic Information:
    - Connect App Name: **Electric Imp SmartFridge**
    - API Name will automatically become **Electric_Imp_SmartFridge**
    - Contact Email: enter your email address
  - API (Enable OAuth Settings):
    - Check the **Enable OAuth Settings** Box
    - **Callback URL**: enter the agent URL of your device (copy it from impCentral -- see the previous step)
    - **Selected OAuth Scopes**:
      - Select **Access and manage your data (api)**
      - Click **Add**:
![Salesforce Connected App](https://imgur.com/YcRqCXy.png)
  - Click **Save**
  - Click **Continue**
- You will be redirected to your Connected App’s page
  - Make a note of your **Consumer Key** (you will need to enter it into your agent code)
  - Click **Click to reveal** next to the Consumer Secret field
  - Make a note of your **Consumer Secret** (you will need to enter it into your agent code):
![Salesforce Keys](https://imgur.com/XpJXq1I.png)
- Do not close the Salesforce page

#### Adding API Keys to your Agent Code

- Return to impCentral
- Find the *SALESFORCE CONSTANTS* section at the end of the agent code and enter your **CONSUMER_KEY** and **CONSUMER_SECRET** constants (copy their values from the Salesforce Connected App’s page):
![IDE with code](https://imgur.com/DKc0Kyr.png)
- Do not close impCentral

### Step 5: Create a Custom Object in Salesforce

The Custom Object will be used to store the data received from the device.

- Return to the Salesforce page
- Click the **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Click on the **Object Manager** tab next to **Home**:
![Object Manager](https://imgur.com/bJhA9xk.png)
- Click on the **Create** drop-down and then select **Custom Object**:
![Custom Object Create](https://imgur.com/0uYtuPk.png)
- In the **New Custom Object** form fill in:
    - Custom Object Information
      - Label: **SmartFridge**
      - Plural Label: **SmartFridges**
      - Object Name: **SmartFridge**
    - Enter the Record Name Label and Format:
      - Record Name: **Reading Id** (replace the default **SmartFridge Name**)
      - Data Type: **Auto Number**
      - Display Format: **R-{0000}**
      - Starting Number: **1**
![Custom Object Info](https://imgur.com/w4J67Jq.png)
    - Click **Save**
- On the **SmartFridge** Custom Object page, make sure that **API Name** is **SmartFridge__c**:
![Custom Object Api Name](https://imgur.com/y5spRHY.png)

- Select the **Fields & Relationships** section from the left navigation
  - Click **New**
- Create a field for the temperature:
  - **Step 1. Choose the field type** 
    - Choose Data Type: **Number**
    - Click **Next**
  - **Step 2. Enter the details**:
    - Field Label: **temperature**
    - Length: **4**
    - Decimal Places: **2**
    - Field Name: **temperature**:
![Temperature Field](https://imgur.com/40XLV2B.png)
  - Click **Next**, **Next**, and then **Save & New**
- Create a field for the humidity:
  - **Step 1. Choose the field type** 
    - Choose Data Type: **Number**
    - Click **Next**
  - **Step 2. Enter the details**:
    - Field Label: **humidity**
    - Length: **4**
    - Decimal Places: **2**
    - Field Name: **humidity**
  - Click **Next**, **Next**, and then **Save & New**
- Create a field for the door status:
  - **Step 1. Choose the field type**
    - Choose Data Type: **Picklist**
    - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **door**
    - Values: Select **Enter values, with each value separated by a new line**
    - Enter **Open** and **Closed** so that they are on separate lines.
    - Field Name: **door**
![Door Field](https://imgur.com/XqAEQ10.png)
  - Click **Next**, **Next**, and then **Save & New**
- Create a field for the timestamp:
  - **Step 1. Choose the field type** 
    - Choose Data Type: **Date/Time**
    - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **ts**
    - Field Name: **ts**
  - Click **Next**, **Next**, and then **Save & New**
- Create a field for the device’s ID:
  - **Step 1. Choose the field type**
    - Choose Data Type: **Text**
    - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **deviceId**
    - Length: **16**
    - Field Name: **deviceId**
    - Check **Always require a value in this field in order to save a record**
    - Check **Set this field as the unique record identifier from an external system**
![DeviceId Field](https://imgur.com/WApbOvX.png)
  - Click **Next**, **Next**, and then **Save**

- Make sure that SmartFridge **Fields & Relationships** looks like this:
![SmartFridge Fields](https://imgur.com/10aY29u.png)

### Step 6: Create Platform Events in Salesforce

Platform Events are used to transfer the data from the device to Salesforce cloud. A Platform Event Trigger inserts the received data into the Custom Object.

The Platform Event’s fields must have the names and types mentioned here. If you change anything in the Platform Event definition, you will need to update the imp application’s agent code. The name of the Platform Event is defined in the agent code as a constant, *READING_EVENT_NAME*.

- On the Salesforce page, click the **Setup** icon in the top-right navigation menu and select **Setup**
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Platform Events** into the Quick Find box and then select **Data > Platform Events**:
![Salesforce QuickFind Platform Events](https://imgur.com/CXCuSr1.png)
- Click **New Platform Event**
- In the **New Platform Event** form fill in:
  - Field Label: **Smart Fridge Reading**
  - Plural Label: **Smart Fridge Readings**
  - Object Name: **Smart_Fridge_Reading**
![New Smart Fridge Reading Event](https://imgur.com/4otU27s.png)
  - Click **Save**
- You will be redirected to the **Smart Fridge Reading** Platform Event page. Now you need to create Platform Event fields that correspond to your fridge readings
- In the **Custom Fields & Relationships** section click **New**:
![Smart Fridge Reading Event New Field](https://imgur.com/gbmXQRK.png)
- Create a field for the temperature:
  - Data Type: **Number**
  - Click **Next**
  - Field Label: **temperature**
  - Length: **4**
  - Decimal Places: **2**
  - Field Name: **temperature**
- Click **Save**
- In the **Custom Fields & Relationships** section click **New**
- Create a field for the humidity:
  - Data Type: **Number**
  - Click **Next**
  - Field Label: **humidity**
  - Length: **4**
  - Decimal Places: **2**
  - Field Name: **humidity**
- Click **Save**
- In the **Custom Fields & Relationships** section click **New**
- Create a field for the door status:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **door**
  - Length: **10**
  - Field Name: **door**
- Click **Save**
- In the **Custom Fields & Relationships** section click **New**
- Create a field for the timestamp:
  - Data Type: **Date/Time**
  - Click **Next**
  - Field Label: **ts**
  - Field Name: **ts**
- Click **Save**
- In the **Custom Fields & Relationships** section click **New**
- Create a field for the device’s ID:
  - Data Type: **Text**
  - Click **Next**
  - Field Label: **deviceId**
  - Length: **16**
  - Field Name: **deviceId**
  - Check **Always require a value in this field in order to save a record**
- Click **Save**.
- Make sure that **Smart Fridge Reading API Name** is **Smart_Fridge_Reading__e** and **Custom Fields & Relationships** looks like this:
![Smart Fridge Reading Event Details](https://imgur.com/4BQA37p.png)
- Click **New** in **Triggers** section:
![Triggers](https://imgur.com/wEfZ0o8.png)
- Insert the following code:
```
trigger SmartFridgeReadingReceived on Smart_Fridge_Reading__e (after insert) {
  List<SmartFridge__c> records = new List<SmartFridge__c>();
  for (Smart_Fridge_Reading__e event : Trigger.New) {
    SmartFridge__c record = new SmartFridge__c();
    record.deviceId__c = event.deviceId__c;
    record.temperature__c = event.temperature__c;
    record.humidity__c = event.humidity__c;
    record.door__c = event.door__c;
    record.ts__c = event.ts__c;
    records.add(record);
  }
  insert records;
}
```
![Trigger Code](https://imgur.com/sZNPIt3.png)
- Click **Save**
- Return to impCentral
- Find the *SALESFORCE CONSTANTS* section at the end of the agent code and make sure your **READING_EVENT_NAME** constant value is **Smart_Fridge_Reading__e** (ie. the same as **Smart Fridge Reading API Name** value of the just created **Platform Event**):
![IDE with code](https://imgur.com/DKc0Kyr.png)
- Do not close impCentral

### Step 7: Create a Context in Salesforce

This is needed to help create the IoT Explorer Orchestration.

- On the Salesforce page, click the **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Contexts** into the Quick Find box and then select **Feature Settings > IoT Explorer > Contexts**:
![Contexts](https://imgur.com/9Sp7hpy.png)
- Click **New Context**
- In the **New Context** form fill in:
  - Context Name: **Smart Fridge Context**
  - Key Type: **String**
  - Click **Save**
- You will be redirected to the **Smart Fridge Context** page
- In the **Platform Events** section click **Add**:
![Context Add Platform Event](https://imgur.com/ySmNGqq.png)
- In the **Add Platform Event** form fill in:
  - Context: **Smart Fridge Context**
  - Platform Event: choose the **Smart Fridge Reading** Platform Event you created earlier
  - Key: choose **deviceId**
  - Click **Save**

### Step 8: Create a Custom Case Field in Salesforce

This example uses customized Cases which are standard Case objects with an additional field for device ID.

- On the Salesforce page, click **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Click on **Object Manager** tab next to **Home**:
![Object Manager](https://imgur.com/bJhA9xk.png)
- Click the **Case** object
- Select the **Fields & Relationships** section and click the **New** button:
![New Fields and Relationships](https://imgur.com/qCZzI3r.png)

- In the **New Custom Field** form:
  - **Step 1. Choose the field type**
    - Choose Data Type: **Text**
    - Click **Next**
  - **Step 2. Enter the details**:  
    - Field Label: **deviceId**
    - Length: **16**
    - Field Name: **deviceId**
    - Check **Set this field as the unique record identifier from an external system**
![Related Fridge](https://imgur.com/ZN1ekyE.png)
  - Click **Next**, **Next** and then **Save**
- Select the **Fields & Relationships** section and find your newly created **deviceId** custom field
- Make sure the **Field Name** is **deviceId__c**:
![Case Fields](https://imgur.com/3i8uHjK.png)

### Step 9: Create an Orchestration in Salesforce

This example demonstrates how to create an **Orchestration** that defines a fridge state machine, reacts to **Platform Events** and opens **Cases** when:

1. The refrigerator door is opened during three consecutive data readings (the exact threshold is between 30 and 45 seconds), or 
2. The temperature is over 11&deg;C, or
3. The relative humidity is over 70%.

You may set up other thresholds.

#### Creating the Orchestration

- On the Salesforce page, click the **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Orchestrations** into the Quick Find box and then select **Feature Settings > IoT Explorer > Orchestrations**:
![Orchestrations](https://imgur.com/8i2qDU9.png)
- Click **New Orchestration**
- In the **New Orchestration** pop up fill in:
  - Name: **Smart Fridge Orchestration**
  - Context: choose the **Smart Fridge Context** you created earlier
![New Orchestration](https://imgur.com/gWMgKur.png)
  - Click **Create**
  - You will be redirected to the **Smart Fridge Orchestration** page
  
#### Creating Orchestration Variables

- Click on the **VARIABLES** tab. Now you need to create temperature and humidity thresholds, and a door openning counter and limit
- Click **Add Variable**:
![Variables](https://imgur.com/75kHG00.png)
- Create a variable for the temperature threshold:
  - Name: **TEMPERATURE_THRESHOLD**
  - Data Type: **Number**
  - Initial Value: **11** (for 11°C)
- Click **Add Variable**
- Create a variable for the humidity threshold:
  - Name: **HUMIDITY_THRESHOLD**
  - Data Type: **Number**
  - Initial Value: **70** (for 70%)
- Click **Add Variable**
- Create a variable for the door open counter limit:
  - Name: **DOOR_OPEN_LIMIT**
  - Data Type: **Number**
  - Initial Value: **3** (three consecutive data readings with door status)
- Click **Add Variable**
- Create a variable for the door open counter:
  - Name: **door_open_counter**
  - Data Type: **Number**
  - Event Type: **Smart_Fridge_Reading__e** (the Platform Event you created earlier)
  - IF: `Smart_Fridge_Reading__e.door__c = "open"`
  - Value: **Count 40 sec** (three consecutive data readings fit in 40 seconds)
  - Initial Value: **0**
- Make sure your Orchestration variables looks like this:
![Orchestration variables](https://imgur.com/foaGmIW.png)

#### Creating Orchestration Global Rules

- Click on the **GLOBAL RULES** tab.
- In the **When** column of **Global rules** choose **Smart_Fridge_Reading__e**
- In the **IF** column add `Smart_Fridge_Reading__e.door__c = "closed"`
- In the **Action** column choose **Reset Variable** and choose **door_open_counter**
- Make sure your **GLOBAL RULES** looks like this:
![Global rules](https://imgur.com/JIuP8sO.png)

#### Creating Orchestration Rules: Door Open Rule

- Click **Add State**:
![Add State](https://imgur.com/Qo93sKR.png)
- Enter **Door Open** as the new state name
- In the **When** column of the **Door Open** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
- In the **Condition** column enter `Smart_Fridge_Reading__e.door__c = "closed"`
- In the **Transition** column choose **Default**:
![Door Open State](https://imgur.com/dIqjY9S.png)
- In the **When** column of the **Default** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
- In the **Condition** column enter `door_open_counter >= DOOR_OPEN_LIMIT`
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
- In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
![Door Open Case create](https://imgur.com/PdcE9Zv.png)
- In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Click **Add Field**
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Refrigerator Door Open"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"door has been opened for too long"`
- In **Action Name** field enter **Create Door Open Case**
- Make sure that **Assign values to record fields** table looks like this:
![Door Open Case fields](https://imgur.com/3UvtEfs.png)
- Click **Finish**
- In the **Transition** column choose **Door Open**:
![Default To Door Open](https://imgur.com/rtTY6Om.png)

#### Creating Orchestration Rules: Temperature Over Threshold Rule

- Click **Add State**
- Enter **Temperature Over Threshold** as the new state name
- In the **When** column of the **Temperature Over Threshold** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
- In the **Condition** column enter `Smart_Fridge_Reading__e.temperature__c < TEMPERATURE_THRESHOLD`
- In the **Transition** column choose **Default**:
![Temperature State](https://imgur.com/7AOXeUL.png)
- Click **Add rule** in the **Default** state menu:
![Default Add rule](https://imgur.com/hhJG3NF.png)
- In the **When** column the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
- In the **Condition** column enter `Smart_Fridge_Reading__e.temperature__c >= TEMPERATURE_THRESHOLD`
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
- In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
- In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Temperature Over Threshold"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"current temperature " + TEXT(Smart_Fridge_Reading__e.temperature__c) + " is over threshold"`
- In **Action Name** field enter **Create Temperature Case**
- Make sure that **Assign values to record fields** table looks like this:
![Temperature State Case fields](https://imgur.com/0PR5YdB.png)
- Click **Finish**
- In the **Transition** column choose **Temperature Over Threshold**:
![Default To Temperature transition](https://imgur.com/M3T8ErX.png)

#### Creating Orchestration Rules: Humidity Over Threshold Rule

- Click **Add State**
- Enter **Humidity Over Threshold** as the new state name
- In the **When** column of the **Humidity Over Threshold** state click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
- In the **Condition** column enter `Smart_Fridge_Reading__e.humidity__c < HUMIDITY_THRESHOLD`
- In the **Transition** column choose **Default**:
![Humidity State](https://imgur.com/esSYDgq.png)
- Click **Add rule** in the **Default** state menu
- In the **When** column the new rule click **Select when to evaluate rule** and choose **Smart_Fridge_Reading__e**
- In the **Condition** column enter `Smart_Fridge_Reading__e.humidity__c >= HUMIDITY_THRESHOLD`
- In the **Actions** column click **Add an action** and choose **OUTPUT ACTIONS > Salesforce Record**
- In the **New Salesforce Output Action** pop up choose: 
  - Object: **Case**
  - Action Type: **Create**
- In the **Assign values to record fields** table:
  - Click **Add Field**
  - Choose **deviceId__c** in **Select field**
  - Enter value: `Smart_Fridge_Reading__e.deviceId__c`
  - Choose **Subject** in **Select field**
  - Enter **Subject** value: `"Humidity Over Threshold"`
  - Click **Add Field**
  - Choose **Description** in **Select field**
  - Enter **Description** value: `"current humidity " + TEXT(Smart_Fridge_Reading__e.humidity__c) + " is over threshold"`
- In **Action Name** field enter **Create Humidity Case**
- Make sure that **Assign values to record fields** table looks like this:
![Humidity State Case fields](https://imgur.com/9ao8KWL.png)
- Click **Finish**
- In the **Transition** column choose **Humidity Over Threshold**:
![Default To Humidity transition](https://imgur.com/e0YnsY4.png)

#### Orchestration Activation

- Click on **STATES** tab. Make sure that your States diagram looks like this:
![States](https://imgur.com/Noz1EXu.png)
- Click on **Activate** button. In the pop up click **Activate**:
![Activate](https://imgur.com/H7zBYSy.png)
- Do not close Salesforce page

### Step 10: Build and Run the Electric Imp Application

- Return to impCentral
- Make sure your device is online (powered on and connected to WiFi; impCentral shows the device is online)
- Click the **Build & Run All** button to check, compile and deploy the code
- Look at the log window to see the logs from your running application
- If you see `"\[Agent] ERROR: Not logged into Salesforce."`, it means your application is not authorized to connect to Salesforce
  - This example uses OAuth 2.0 for authentication. The agent has been set up as a web server to handle the authentication procedure. Click on the agent URL in impCentral:
![IDE Screenshot](https://imgur.com/6rm6FBf.png)
  - You will be redirected to the login page
  - Log into Salesforce on that page
  - If login is successful the page should display **"Authentication complete - you may now close this window"**
  - Close that page and return to impCentral
- Make sure there are no more errors in the logs
- Make sure there are periodic logs like this: `"\[Agent] Readings sent successfully"`
- Your application is now up and running

### Step 11: Place the impExplorer Kit in a Refrigerator

Open your refrigerator and place the impExplorer Kit on a shelf in your refrigerator door.

![Imp In Fridge](http://i.imgur.com/z5llZBg.png)

If you don't have a fridge handy for this scenario, you can test the example behavior by emulating different conditions. For example, you can emulate a fridge door being open or closed by placing the impExplorer under a light or into a really dark place. Emulate the high temperature case by moving the device from a cold place to a much warmer one.

### Step 12: Monitor the Data

You can use the Salesforce1 mobile app to see the data which your device sends. 

#### Create a Custom Object Tab

This is needed to make the Custom Object with the stored data from the device accessible by Salesforce1.

- On the Salesforce page, click **Setup** icon in the top right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Tabs** into the Quick Find box and then select **User Interface > Tabs**
- Under **Custom Object Tabs**, click **New**
- Choose **SmartFridge** from the Object dropdown
- Choose **Thermometer** as the Tab Style:  
![Custom Object](http://i.imgur.com/eXyOmd6.png)
- Click **Next**, **Next**, and then **Save**

#### Check Salesforce1 is Enabled

Ensure that Salesforce1 is available and enabled for you:

- On Salesforce page, click the **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Salesforce1** into the Quick Find box and then select **Apps > Mobili Apps > Salesforce1 > Salesforce1 Settings**
- Make sure the **Enable the Salesforce1 mobile browser app** is checked:  
![App settings checkbox](http://i.imgur.com/Tigi9eK.png)
- Enter **Users** into the Quick Find box and select **Users > Users**
- Click **Edit** next to your username
- Make sure that **Salesforce1 User** is checked. If not, check it and click **Save**: 
![Salesforce1 User checkbox](http://i.imgur.com/svdRddT.png)

#### Run Salesforce1

You can access and run Salesforce1 in three ways:

- As a downloadable mobile app that you install and run on your phone from the Apple iTunes Store or Google Play. This is the most easy way, and the one we recommend.
- By opening the **login.salesforce.com** page in a browser on your phone
- By using the Chrome Developer Tools (described below)

#### Open Salesforce1 in Chrome Browser

Use this approach if you want or need to run Salesforce1 on your PC, not on a mobile phone. It is possible to emulate Salesforce1 in the Chrome web browser.

- On the Salesforce page, click the **Setup** icon in the top- right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Copy the current opened URL into clipboard
- Open a new tab in your Chrome browser
- Open the Developer Tools by clicking *View* | *Developer* | *Developer Tools*
- Click the **Toggle Device Mode** button to simulate your browser as a mobile device: 
![Chrome Tools Mobile Simulator](http://i.imgur.com/hzb2F0N.png)
- Paste from clipboard the URL you copied before. Do not press Enter
- Remove the part of the URL immediately after `lightning.force.com`. For example:  
![URL original](https://imgur.com/UZYqV21.png)
![URL removed](https://imgur.com/jPYa1t7.png)
- Append `/one/one.app` to the end of the URL after salesforce.com. For example:  
![URL one/one.app](https://imgur.com/V0Deg1d.png)
- Press Enter. Salesforce1 emulation will be started in the Chrome Browser
- If the display is too small, change the size to 100%: 
![URL one/one.app](http://i.imgur.com/BvmL50q.png)
- Click the three white bars in the upper left to open the navigation panel
- Under the **Recent** section, scroll down and click *More*:
![Menu](http://i.imgur.com/xv2YL52.png)
- You will see **SmartFridges** somewhere on the list. Click *SmartFridges*:
![Menu](http://i.imgur.com/GHcC0gG.png)
- Select a record to view the details of the reading:  
![Reading record](https://imgur.com/d3N5N7F.png)

### Step 13: Monitor Orchestration State Transitions and Cases

You can see transitions between the states which you defined in IoT Explorer Orchestration as well as registered Cases.

- On the Salesforce page, click the **Setup** icon in the top-right navigation menu and select **Setup**:
![Salesforce Navbar](https://imgur.com/AJFyqgk.png)
- Enter **Orchestrations** into the Quick Find box and then select **Feature Settings > IoT Explorer > Orchestrations**:
![Orchestrations](https://imgur.com/8i2qDU9.png)
- Click on **Smart Fridge Orchestration**
- Click on **TRAFFIC** tab
- If your impExplorer is in a fridge, you can see that your device is in **Default** normal state:
![Default state](https://imgur.com/XQ0DyYd.png)
- Keep the fridge door open for over 45 seconds (or just place the device to a lit room)
- On the **TRAFFIC** tab see that your device moved into **Door Open** state:
![Door Open state](https://imgur.com/h2Hdeg5.png)
- Move the imp device to a warm dark place
- On the **TRAFFIC** tab see that your device moved into **Temperature Over Threshold** state:
![Temperature state](https://imgur.com/z7uB2CD.png)
- Run Salesforce1 as described in the previous Step
- Click the three white bars in the upper left to open the navigation panel
- Under the "Recent" section, click **Cases**:
![Cases menu](https://imgur.com/fGVaet7.png)
- You will see the registered Cases:  
![Cases](https://imgur.com/WDGJrUp.png)
