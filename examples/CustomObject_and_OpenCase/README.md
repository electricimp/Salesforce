# Salesforce Examples #

The following examples will use a Salesforce Connected App for communication between the imp and Salesforce. These examples require you to have an [Electric Imp developer account](https://impcentral.electricimp.com), the Electric Imp mobile app, a [Salesforce developer account](https://developer.salesforce.com/signup?d=70130000000td6N) and the hardware listed below.

Please note that these instructions are not actively updated. If any errors are found, please submit pull requests to help us maintain these examples. 

## Hardware ##

These examples use an imp001, an [April breakout board](https://developer.electricimp.com/hardware/resources/reference-designs/april) and an Env(ironmental sensor) Tail to collect data. 

**Note** The Tails hardware used in these examples is no longer available to purchase. If you already have an April with an Env Tail, you can follow the instructions below, otherwise please get started with the Smart Refrigerator example found in the *SmartRefrigerator* folder. 

If you need guides to help you get started with the Electric Imp platform, please visit the [Dev Center’s Getting Started Guide](https://developer.electricimp.com/gettingstarted).

## Getting Started ##

Create a Product and a Development Device Group in impCentral, and, after BlinkUp, assign your device to this Device Group. 

Now choose the example you wish to use: *Open a Case*, *Custom Object - Create a Record*, or *Custom Object - Update a Record*. Copy and paste the corresponding example code into the agent and device code panes within the Device Group’s code editor. Select your device and make a note of your agent URL, which can be found at the top of the code editor’s logging pane when the device is selected. The URL will look something like this: `"https://agent.electricimp.com/szPc0sLfAqlu"`. You will need the agent URL when creating your Connected App in Salesforce.

### Creating a Connected App in Salesforce ###

Please follow these step-by-step instructions to create a Connected App:

  1. Log into Salesforce and click on the **Setup** tab in the top right navigation menu.
  2. In the sidebar under **Build**, unfold the **Create** menu and select **Apps**.
  3. At the bottom of the page under **Connected apps**, click the **New** button.
  4. In the **New Connected App** form, fill in:
    - Basic Information:
      - Connected App Name.
      - API Name.
      - Contact Email.
    - API (Enable OAuth Settings):
      - Check the *Enable OAuth Settings* Box.
      - Callback URL &mdash; this should be your agent URL.
      - Selected OAuth Scopes:
        - Select **Access and manage your data (api)**.
        - then click **Add**.
    - When the above information has been entered, click **Save**.
  5. You will be redirected to the **Connected App Name - your app name** page:
    - Make a note of your Consumer Key (you will need to enter this in your agent code).
    - Click on **Consumer Secret — Click to reveal**.
    - Make note of your Consumer Secret (you will need to enter this in your agent code).

Go back to impCentral and the Development Device Group code editor. Find the *SALESFORCE CONSTANTS* section in the agent code and enter your Consumer Key and Consumer Secret.

**Note** These instructions were written in March 2016 and may no longer be consistent with the latest Salesforce web portal.

## Open a Case Example ##

In this example, the imp will open a case in Salesforce if the agent determines readings to be outside given ranges. The device takes temperature, humidity and ambient light readings every three seconds then passes these readings to the agent. The agent runs some logic to determine if the temperature has gone above 29°C or below 20°C, or if the ambient light has gone below 20 lux. If any of these conditions have been met, a case will be opened in Salesforce with the details of the event that triggered the case. No further setup is requires for this example. Please skip to the [‘Launch Your App’](#launch-your-app) section.

## Custom Object Examples ##

There are two examples using an imp and a Salesforce custom object. The **Create Custom Object** example creates a record every time new data is available. In the **Update Custom Object** example, a single record is created and then updated every time new data is available. In both examples the device takes temperature, humidity, air pressure and ambient light readings every five minutes then sends those readings to the agent. The agent then either creates or updates a record in Salesforce with the new readings.

### Creating a Custom Object in Salesforce ###

These examples require a little more setup work in Salesforce than the earlier examples do. You will need to create a custom object with fields that correspond to each reading. Please follow these step-by-step instructions for creating a Custom Object:

1. Log into Salesforce and click on the **Setup** tab in the top right navigation menu.
2. In the sidebar under **Build**, unfold the **Create** menu and select **Objects**.
3. At the top of the page, click the **New Custom Object** button.
4. In the **New Custom Object** form enter:
    - Custom Object Information:
      - **Label** &mdash; for example `Env_Tail_Reading`.
      - **Plural Label** &mdash; for example `Env_Tail_Readings`.
      - **Object Name** &mdash; for example `Env_Tail_Reading`.
    - Enter Record Name Label and Format:
      - **Record Name** &mdash; for example `Reading Id`.
      - **Data Type** select **Auto Number**.
      - **Display Format** &mdash; for example `*R-{0000}*`.
      - **Starting Number** &mdash; `0`.
    - When the above information has been entered, click **Save**.
5. On the **Custom Objects Page**, click on your object name.
6. You will be redirected to the *Custom Object - your object name* page. You will now need to repeat step 7 four times to add fields for each of the sensor readings collected. The **Field Name** must match the data table from the device. The **Field Names** in the example code are: **temperature**, **humidity**, **pressure** and **amb_lx**.
7. At the bottom of the page, under **Custom Fields & Relationships**, click the **New** button.
    - Step 1 of 4, *Data Type*:
      - Select **Number**.
      - Click **Next**.
    - Step 2 of 4:
      - Enter **Field Label** &mdash; for example `temperature`.
      - Enter **Length** &mdash; for example `4`.
      - Enter **Decimal Places** &mdash; for example `2`.
      - Enter **Field Name** &mdash; for example `temperature`.
      - Enter **Description** &mdash; for example `Temperature reading in °C`,
      - Click **Next**.
    - Step 3 of 4:
      - Click **Next** again.
    - Step 4 of 4:
      - Click **Save & New**
    - **Repeat Steps 1-4** for **humidity**, **pressure** and **amb_lx**.
8. You need to create one more Field: the *Device Id field*<br>**Note** Step 2 of 4 is slightly different for the **Update Custom Object** and **Create Custom Object** examples.
    - Step 1 of 4, *Data Type*:
      - Select **text**.
      - Click **Next**.
    - Step 2 of 4:
      - Under **Field Label** enter `deviceId`.
      - Enter **Length** &mdash; for example `32`.
      - Under **Field Name** enter `deviceId`.
    - Check **Required**
    - For the *Updating a Custom Object* example **ONLY** do these three additional steps:
        - Check **Unique**.
        - Check **Test "ABC" and "abc" as different values (case sensitive)**.
        - Check **External ID**.
        - Click **Next**.
    - Step 3 of 4:
      - Click **Next** again.
    - Step 4 of 4:
      - Click **Save**.
9. You will be redirected to the *Custom Object - your object name* page. Make a note of your **API Name** as you will need to enter this into your agent code.

Go back to impCentral and the Development Device Group code editor. In the *APPLICATION CODE* section of the agent code, find the *RUNTIME VARIABLES* (this will be towards the bottom) and set the *obj_api_name* variable to your **API Name**. If you named your Custom Object *Env_Tail_Reading* you will be able to skip this step. You are now ready to [Launch Your App](#launch-your-app).

**Note** These instructions were written in March 2016 and may no longer be consistent with the latest Salesforce web portal.

## Launch Your App ##

These examples use OAuth 2.0 for authentication so the agent has been set up as a web server to handle the login.

Make sure your device is selected in the impCentral code editor.

- Hit **Build and Force Restart** to save and launch the code.
- Click on the agent URL (at the top of the logging pane) to launch the login webpage.
- Log into Salesforce.

Your Connected App should now be up and running. You can monitor the device logs in impCentral, or log into the Salesforce web portal to see updates there.
