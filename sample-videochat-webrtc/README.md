# Overview
The VideoChat code sample allows you to easily add video calling and audio calling features into your iOS app with [QuickBlox](https://quickblox.com). Enable a video call function similar to FaceTime or Skype using this code sample as a basis.

It is based on WebRTC technology.

This code sample is written in *Objective-C* lang.
The same is also available in [Swift](https://github.com/QuickBlox/quickblox-ios-sdk/blob/master/sample-videochat-webrtc-swift) lang.

# Credentials

Welcome to QuickBlox [Credentials](https://docs.quickblox.com/docs/ios-quick-start), where you can get your credentials in just 5 minutes! All you need is to:

1. Register a free QuickBlox account and add your App there.
2. Update credentials in your [Application Code](https://docs.quickblox.com/docs/ios-setup#initialize-quickblox-sdk).

# Main features
* 1-1 video calling
* Group video calling
* Screen sharing
* Mute/Unmute audio/video streams
* Display bitrate
* Switch video input device (camera) 
* [CallKit](https://developer.apple.com/documentation/callkit) supported
* WebRTC Stats reports
* H264,VP8,H264High video codecs supported
* Lots of different settings related to call quality 

Original sample description & setup guide - [Sample-webrtc-ios](https://docs.quickblox.com/docs/ios-video-calling)

# The Сhanges VOIP on iOS 13

With the changes VOIP on iOS 13 enforced and outlined in https://developer.apple.com/videos/play/wwdc2019/707/ and https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry/,
Now, when we receive a VOIP Push in the background, we are forced to immediately report an incoming call before the session of this call arrives. To improve user experience, we added some additional information about this call to the VoIP payload of the outgoing call push:

let payload = ["message": "\(opponentName) is calling you.",
    "ios_voip": "1",
    "VOIPCall": "1",
    "sessionID": session.id, - this is the session ID (String) that the call initiator created, added to payload so that the opponent can know the session ID that should arrive to him and correctly manage incoming sessions;
    "opponentsIDs": allUsersIDsString, - this is the string from the IDs of all participants in the call, separated by a comma, with the initiator in the first place, in payload, added so that the opponent could know the opponentsIDs of this session before the session;
    "contactIdentifier": allUsersNamesString, - this is the string from fullName of all call participants separated by a comma, with the initiator in the first place !!!, added to payload so that the opponent could know the names of the participants of this session before the session arrives and display them on the CallKit screen;
    "conferenceType" : conferenceTypeString - this is the string (let conferenceTypeString = conferenceType == .video? "1": “2”), added to payload so that the opponent can know the conferenceType (“video” or “audio”) of this session before the session arrives and correctly configure the CallKit screen;
    “timestamp”: timestamp - this is the string from the date of sending the VOIP Push, it's added to payload for the case when there is bad Internet  and the push is delivered for a long time and may come when the call initiator completes the call automatically. Upon receiving  of the push, we compare the date of departure and the date of receiving and if the delivery time of the push is longer than “answerTimeInterval” - do not show the call;
]

# CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1+ is required to build project with QuickBlox 2.17.7+ and Quickblox-WebRTC 2.7.4+.

To integrate QuickBlox and Quickblox-WebRTC into the **sample-videochat-webrtc-objc** run the following command:

```bash
$ pod install
```
Additional libraries used via [CocoaPods](https://cocoapods.org):

* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD.git/)
