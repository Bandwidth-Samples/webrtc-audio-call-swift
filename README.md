# WebRTC Audio Call
<a href="http://dev.bandwidth.com"><img src="https://s3.amazonaws.com/bwdemos/BW-VMP.png"/></a>
</div>

 # Table of Contents

<!-- TOC -->

- [WebRTC Audio Call](#webrtc-audio-call)
- [Description](#description)
- [Bandwidth](#bandwidth)
- [Environmental Variables](#environmental-variables)
- [Callback URLs](#callback-urls)
    - [Ngrok](#ngrok)

<!-- /TOC -->

# Description
This sample allows for an iOS device to call a phone number using WebRTC audio.

# Setup

In order to run this sample `WebRTC Audio` is required to be enabled on your account. Please check with your account manager to ensure you are properly provisioned.

## Configure your HTTP server

Copy the default configuration file `.env.default` to `.env`.

```bash
cp .env.default .env
```

Add your Bandwidth account settings to the new configuration file `.env`.

Bandwidth account credentials
- BW_ACCOUNT_ID
- BW_USERNAME
- BW_PASSWORD

Voice application id from Bandwidth
- BW_VOICE_APPLICATION_ID

Bandwidth phone number which is the calling from phone number
- BW_NUMBER

Phone number which is the calling to phone number
- USER_NUMBER

Your server, e.g. ngrok server, with trailing slash
- BASE_CALLBACK_URL

Install server dependencies and run.

```bash
npm install
node server.js
```

## Configure your iOS project

Open the `WebRTCVideoStoyboard` project in Xcode.

Add a property list file `Config.plist` to your project. This should be added to the `WebRTCAudioStoryboard` folder alongside `Info.plist`.

Add a row to the `Config.plist` property list file with a key `Address` and type `String`. Set the value of the row to the server application address which is accessible to the iOS devices. An ngrok url works well for this.

With the server project running build and run the iOS project on your device from Xcode.

While the device is running the app tap `Connect`. Permissions to your microphone may need to be granted at this time. Once connected tap the large green button to start your phone call.

# Bandwidth

In order to use the Bandwidth API users need to set up the appropriate application at the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and create API credentials.

To create an application log into the [Bandwidth Dashboard](https://dashboard.bandwidth.com/) and navigate to the `Applications` tab.  Fill out the **New Application** form selecting the service (Messaging or Voice) that the application will be used for.  All Bandwidth services require publicly accessible Callback URLs, for more information on how to set one up see [Callback URLs](#callback-urls).

For more information about API credentials see [here](https://dev.bandwidth.com/guides/accountCredentials.html#top)

# Environmental Variables
The sample app uses the below environmental variables.
```sh 
BW_ACCOUNT_ID                 # Your Bandwidth Account Id
BW_USERNAME                   # Your Bandwidth API Username
BW_PASSWORD                   # Your Bandwidth API Password
BW_NUMBER                     # Your Bandwidth Phone Number
BW_VOICE_APPLICATION_ID       # Your Voice Application Id created in the dashboard
USER_NUMBER                   # Phone number which is the calling to phone number
BASE_CALLBACK_URL             # Your server, e.g. ngrok server, with trailing slash
```

# Callback URLs

For a detailed introduction to Bandwidth Callbacks see https://dev.bandwidth.com/guides/callbacks/callbacks.html

Below are the callback paths:
* `/callAnswered`

## Ngrok

A simple way to set up a local callback URL for testing is to use the free tool [ngrok](https://ngrok.com/).  
After you have downloaded and installed `ngrok` run the following command to open a public tunnel to your port (`$PORT`)
```cmd
ngrok http $PORT
```
You can view your public URL at `http://127.0.0.1:{PORT}` after ngrok is running.  You can also view the status of the tunnel and requests/responses here.
