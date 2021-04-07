# Overview
QuickBlox iOS Sample Chat (Swift)

This is a code sample for [QuickBlox](https://quickblox.com) platform. It is a great way for developers using QuickBlox platform to learn how to integrate private and group chat, add text and image attachments sending into your application.

# Credentials

Welcome to QuickBlox [Credentials](https://docs.quickblox.com/docs/ios-quick-start), where you can get your credentials in just 5 minutes! All you need is to:

1. Register a free QuickBlox account and add your App there.
2. Update credentials in your [Application Code](https://docs.quickblox.com/docs/ios-setup#get-application-credentials)

# Chat Sample

This Sample demonstrates how to work with [Chat](https://docs.quickblox.com/docs/ios-chat) QuickBlox module. 

It allows to:

1. Authenticate with Quickblox Chat and REST.
2. Receive and display list of dialogs.
3. Modify dialog by adding occupants.
4. Real-time chat messaging and attachment's handling.
5. [Push notification](https://docs.quickblox.com/docs/ios-push-notifications) receiving functionality.

# Views

* Authorization view.
* List of user's dialog.
* Dialog chat view.
* Dialog chat info.
* New dialog view.
* Edit dialog view.

# Quick Start

To run a code sample, follow the steps below:

1. Install [CocoaPods](https://cocoapods.org) to manage project dependencies.

```
bash
$ sudo gem install cocoapods
```
2. Clone repository with the sample code.
3. Open a terminal and enter the command below in your project path to integrate QuickBlox into the sample.
```
bash
$ pod install
```
4. [Get application credentials](https://docs.quickblox.com/docs/ios-quick-start#get-application-credentials) and get applicationID ,authKey, authSecret, and accountKey.
5. Put the received credentials in AppDelegate file located in the root directory of your project.

```
QBSettings.applicationID = 92
QBSettings.authKey = "wJHdOcQSxXQGWx5"
QBSettings.authSecret = "BTFsj7Rtt27DAmT"
QBSettings.accountKey = "7yvNe17TnjNUqDoPwfqp"
```
6. Run the code sample.


Additional libraries used via [CocoaPods](https://cocoapods.org):

* [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD.git/)
* [SDWebImage](https://github.com/rs/SDWebImage.git)
* [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel.git)

# Documentation

Original sample description & setup guide - [iOS Chat Sample](https://docs.quickblox.com/docs/ios-chat)
