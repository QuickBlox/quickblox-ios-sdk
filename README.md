# QuickBlox 
Core SDK:
[![CocoaPods](https://img.shields.io/cocoapods/v/QuickBlox.svg)](https://cocoapods.org/pods/QuickBlox)
[![CocoaPods](https://img.shields.io/cocoapods/dt/QuickBlox.svg)](https://cocoapods.org/pods/QuickBlox)
[![CocoaPods](https://img.shields.io/cocoapods/dm/QuickBlox.svg)](https://cocoapods.org/pods/QuickBlox)

WebRTC SDK:
[![CocoaPods](https://img.shields.io/cocoapods/v/Quickblox-WebRTC.svg)](https://cocoapods.org/pods/Quickblox-WebRTC)
[![CocoaPods](https://img.shields.io/cocoapods/dt/Quickblox-WebRTC.svg)](https://cocoapods.org/pods/Quickblox-WebRTC)
[![CocoaPods](https://img.shields.io/cocoapods/dm/Quickblox-WebRTC.svg)](https://cocoapods.org/pods/Quickblox-WebRTC)

<br>
QuickBlox - Communication & cloud backend platform which brings superpowers to your mobile apps.

QuickBlox is a suite of communication features & data services (APIs, SDKs, code samples, admin panel, tutorials) which help digital agencies, mobile developers and publishers to add great functionality to smartphone applications. 
Please read full iOS SDK documentation on the [QuickBlox website, iOS section](http://quickblox.com/developers/IOS).

# QuickBlox iOS Samples

This project contains QuickBlox iOS Samples and latest version of SDK, that includes:

* [Framework](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/Framework)
* Samples (separated samples for each QuickBlox module):
  * [Obj-C Chat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-chat)
  * [Swift Chat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-chat-swift)
  * [VideoChat WebRTC Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-videochat-webrtc)
  * [Push Notifications Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-messages)
  * [Location Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-location)
  * [Users Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-users)
  * [Custom Objects Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-custom_objects)
  * [Content Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-content)

  Additional submodules:
  * [QMChatViewController](https://github.com/QuickBlox/QMChatViewController-ios)
  * [QMServices](https://github.com/QuickBlox/q-municate-services-ios)

## Requirements

* Xcode 7+
* iOS SDK 7+

## How to start

Clone repository.

### Clone submodules

If you are using [SourceTree](https://www.sourcetreeapp.com), it will clone submodules automatically.

If you use Terminal:

```
git submodule init
git submodule update
git submodule foreach git pull origin master
```

### Open project

Choose sample you want to try, open it, launch. That's all.

## Documentation

* [Project page on QuickBlox developers section](http://quickblox.com/developers/IOS)
* [Framework reference in AppleDoc format](http://cocoadocs.org/docsets/QuickBlox/)

Detailed information for each sample is also available in *README.md* of each sample folder.

## See also

* [QuickBlox REST API](http://quickblox.com/developers/Overview)
