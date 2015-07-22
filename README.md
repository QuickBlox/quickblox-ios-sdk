# QuickBlox 

[![Join the chat at https://gitter.im/QuickBlox/quickblox-ios-sdk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/QuickBlox/quickblox-ios-sdk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
QuickBlox - Communication & cloud backend (BaaS) platform which brings superpowers to mobile apps. 

QuickBlox is a suite of communication features & data services (APIs, SDKs, code samples, admin panel, tutorials) which help digital agencies, mobile developers and publishers to add great functionality to smartphone applications. 

Please read full iOS SDK documentation on the [QuickBlox website, iOS section](http://quickblox.com/developers/IOS)

# QuickBlox iOS SDK

This project contains QuickBlox iOS SDK, that includes

* [framework](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/Framework)
* samples (separated samples for each QuickBlox module)
  * [Chat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-chat)
  * [VideoChat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-videochat-webrtc)
  * [Push Notifications Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-messages)
  * [Location Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-location)
  * [Users Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-users)
  * [Custom Objects Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-custom_objects)
  * [Content Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-content)

## How to start

To start work you should just put framework into your project and call desired methods.

Latest framework file you can download from [GitHub](https://github.com/QuickBlox/quickblox-ios-sdk/archive/master.zip).

## Documentation

* [Project page on QuickBlox developers section](http://quickblox.com/developers/IOS)
* [Framework reference in AppleDoc format](http://sdk.quickblox.com/ios/documentation/)

## First step

iOS SDK is really simple to use. Just in few minutes you can power your mobile app with huge amount of awesome communication features & data services.

### 1. Get app credentials

* [How to get app credentials](http://quickblox.com/developers/Getting_application_credentials)

### 2. Create new iOS project
### 3. Add [framework](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/Framework) to project, see [this tutorial](http://quickblox.com/developers/IOS-how-to-connect-Quickblox-framework)
### 4. Make QuickBlox API calls

The common way to interact with QuickBlox can be presented with following sequence of actions:

1. [Initialize framework with application credentials](#41-initialize-framework-with-application-credentials)
2. [Create session](#42-create-session)
3. [Login with existing user or register new one](#43-registerlogin)
4. [Perform actions with QuickBlox communication services and any data entities (users, locations, files, custom objects, pushes etc.)](#44-perform-actions)

#### 4.1 Initialize framework with application credentials

```objectivec
[QBApplication sharedApplication].applicationId = 92;
[QBConnection registerServiceKey:@"wJHdOcQSxXQGWx5"];
[QBConnection registerServiceSecret:@"BTFsj7Rtt27DAmT"];
[QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
```

#### 4.2. Create session

```objectivec
[QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
    //Your Quickblox session was created successfully
} errorBlock:^(QBResponse *response) {
    //Handle error here
}];
```

#### 4.3. Register/login

First create (register) new user

```objectivec
QBUUser *user = [QBUUser user];
user.login = @"garry";
user.password = @"garry5santos";

[QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
    // Success, do something
} errorBlock:^(QBResponse *response) {
    // error handling
}];
```

then authorize user

```objectivec
[QBRequest logInWithUserLogin:@"garry" password:@"garry5santos" successBlock:^(QBResponse *response, QBUUser *user){
    // Request succeded
} errorBlock:^(QBResponse *response) {
    // error handling
    NSLog(@"error: %@", response.error);
}];
```

to authorise user in Chat
```objectivec
QBUUser *currentUser = [QBUUser user];
currentUser.ID = 2569; // your current user's ID
currentUser.password = @"garrySant88"; // your current user's password   
 
// set Chat delegate
[QBChat instance].delegate = self;
 
// login to Chat
[[QBChat instance] loginWithUser:currentUser];
 
#pragma mark -
#pragma mark QBChatDelegate
 
// Chat delegate
-(void) chatDidLogin{
    // You have successfully signed in to QuickBlox Chat
}
```

#### 4.4. Perform actions

Create new location for Indiana Jones

```objectivec
QBLGeoData *location = [QBLGeoData geoData];
location.latitude = 23.2344;
location.longitude = -12.23523;
location.status = @"Hello, world, I'm Indiana Jones, I'm at London right now!";
 
[QBRequest createGeoData:location successBlock:^(QBResponse *response, QBLGeoData *geoData) {
    // Request succeded
} errorBlock:^(QBResponse *response) {
    // error handling
}];
```

or put Image into storage

```objectivec
NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"YellowStar" ofType:@"png"]];

[QBRequest TUploadFile:file fileName:@"Great Image" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
    // File uploaded
} statusBlock:^(QBRequest *request, QBRequestStatus *status) {
    // Progress
    NSLog(@"%f", status.percentOfCompletion);
} errorBlock:nil];

```

iOS Framework provides following classes to interact with QuickBlox API (each class has suite of static methods):

* QBAuth
* QBUsers
* QBChat
* QBCustomObjects
* QBLocation
* QBContent
* QBMessages

## See also

* [QuickBlox REST API](http://quickblox.com/developers/Overview)
