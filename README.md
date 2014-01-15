# QuickBlox 
QuickBlox - Communication & cloud backend (BaaS) platform which brings superpowers to mobile apps. 

QuickBlox is a suite of communication features & data services (APIs, SDKs, code samples, admin panel, tutorials) which help digital agencies, mobile developers and publishers to add great functionality to smartphone applications. 

Please read full iOS SDK documentation on the [QuickBlox website, iOS section](http://quickblox.com/developers/IOS)

# QuickBlox iOS SDK

This project contains QuickBlox iOS SDK, that includes

* [framework](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/Framework)
* [snippets](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/snippets) (shows main use cases of using this one)
* samples (separated samples for each QuickBlox module)
  * [Chat Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-chat)
  * [Push Notifications Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-messages)
  * [Location Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-location)
  * [Users Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-users)
  * [Custom Objects Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-custom-objects)
  * [Content Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-content)
  * [Ratings Sample](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/sample-ratings)

## How to start

To start work you should just put framework into your project and call desired methods.

Latest framework file you can download from [GitHub](https://github.com/QuickBlox/quickblox-ios-sdk/archive/master.zip).

## Documentation

* [Project page on QuickBlox developers section](http://quickblox.com/developers/IOS)
* [Framework reference in AppleDoc format](http://sdk.quickblox.com/ios/)

## Oh, please, please show me the code

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
[QBSettings setApplicationID:92];
[QBSettings setAuthorizationKey:@"wJHdOcQSxXQGWx5"];
[QBSettings setAuthorizationSecret:@"BTFsj7Rtt27DAmT"];
```

#### 4.2. Create session

```objectivec
[QBAuth createSessionWithDelegate:self];

- (void)completedWithResult:(Result *)result{
    if(result.success && [result isKindOfClass:QBAAuthSessionCreationResult.class]){
        // Success, do something
    }
}
```

#### 4.3. Register/login

First create (register) new user

```objectivec
QBUUser *user = [QBUUser user];
user.login = @"garry";
user.password = @"garry5santos";

[QBUsers signUp:user delegate:self];

- (void)completedWithResult:(Result *)result{
    if(result.success && [result isKindOfClass:QBUUserResult.class]){
        // Success, do something
        QBUUserResult *userResult = (QBUUserResult *)result;
        NSLog(@"New user=%@", userResult.user);
    }
}
```

then authorize user

```objectivec
[QBUsers logInWithUserLogin:@"garry" password:@"garry5santos"  delegate:self];

- (void)completedWithResult:(Result *)result{
    if(result.success && [result isKindOfClass:QBUUserLogInResult.class]){
        // Success, do something
        QBUUserLogInResult *userResult = (QBUUserLogInResult *)result;
        NSLog(@"Logged In user=%@", userResult.user);
    }
}
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

Send Chat message

```objectivec
// send message
QBChatMessage *message = [QBChatMessage message];
message.recipientID = 546; // opponent's id
message.text = @"Hi mate!";
 
[[QBChat instance] sendMessage:message];
 
 
#pragma mark -
#pragma mark QBChatDelegate
 
- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    NSLog(@"New message: %@", message);
}
```

Create new location for Indiana Jones

```objectivec
QBLGeoData *location = [QBLGeoData geoData];
location.latitude = 23.2344;
location.longitude = -12.23523;
location.status = @"Hello, world, I'm Indiana Jones, I'm at London right now!";

[QBLocation createGeoData:location delegate:self];

- (void)completedWithResult:(Result *)result{
    if(result.success && [result isKindOfClass:QBLGeoDataResult.class]){
        // Success, do something
        QBLGeoDataResult *locationResult = (QBLGeoDataResult *)result;
        NSLog(@"New location=%@", locationResult.geoData);
    }
}
```

or put Image into storage

```objectivec
NSData *file = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"YellowStar" ofType:@"png"]];

[QBContent TUploadFile:file fileName:@"Great Image" contentType:@"image/png" isPublic:YES delegate:self];

- (void)completedWithResult:(Result *)result{
    if(result.success && [result isKindOfClass:QBCFileUploadTaskResult.class]){
        // Success, do something
    }
}
```

iOS Framework provides following classes to interact with QuickBlox API (each class has suite of static methods):

* QBAuth
* QBUsers
* QBChat
* QBCustomObjects
* QBLocation
* QBContent
* QBRatings
* QBMessages

## See also

* [QuickBlox REST API](http://quickblox.com/developers/Overview)
