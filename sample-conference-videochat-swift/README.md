# Overview
QuickBlox provides the Multiparty Video Conferencing solution which allows to setup video conference between 10-12 people. It's built on top of WebRTC SFU technologies.

This code sample is written in *Swift* lang.
Multi-conference server is available only for **Enterprise** plans, with additional **fee**. Please refer to https://quickblox.com/developers/EnterpriseFeatures for more information and contacts.

# Features supported
* Video/Audio Conference with 10-12 people
* Join-Rejoin video room functionality (like Skype)
* Mute/Unmute audio/video stream (own and opponents)
* Display bitrate
* Switch video input device (camera)

# CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1+ is required to build project with QuickBlox 2.17.4+ and Quickblox-WebRTC 2.7.4+.

To integrate QuickBlox and Quickblox-WebRTC into the **sample-conference-videochat-swift** run the following command:

```bash
$ pod install
```
Additional libraries used via [CocoaPods](https://cocoapods.org):

* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD.git/)

# Examples and implementations
**sample-conference-videochat-swift** is a great example of our QuickbloxWebRTC Conference module, classes to look at: **CallViewController**.
