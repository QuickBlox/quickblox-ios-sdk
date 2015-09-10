# QuickBlox 
QuickBlox - Communication & cloud backend (BaaS) platform which brings superpowers to mobile apps. 

QuickBlox is a suite of communication features & data services (APIs, SDKs, code samples, admin panel, tutorials) which help digital agencies, mobile developers and publishers to add great functionality to smartphone applications. 
Please read full iOS SDK documentation on the [QuickBlox website, iOS section](http://quickblox.com/developers/IOS).

# QuickBlox iOS Samples

This project contains QuickBlox iOS Samples and latest version of SDK, that includes:

* [Framework](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/Framework)
* Samples (separated samples for each QuickBlox module):
  * [Obj-C Chat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-chat)
  * [Swift Chat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-chat-swift)
  * [VideoChat WebRTC Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/QBRTCChatSample)
  * [Push Notifications Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-messages)
  * [Location Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-location)
  * [Users Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-users)
  * [Custom Objects Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-custom_objects)
  * [Content Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/develop/sample-content)

  Additional submodules:
  * [QMChatViewController](https://github.com/QuickBlox/QMChatViewController-ios)
  * [QMServices](https://github.com/QuickBlox/q-municate-services-ios)

## Requirements

* Xcode 6+
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
* [Framework reference in AppleDoc format](http://sdk.quickblox.com/ios/documentation)

Detailed information for each sample is also available in *README.md* of each sample folder.

## See also

* [QuickBlox REST API](http://quickblox.com/developers/Overview)
