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

Latest framework file you can download from [downloads page](https://github.com/QuickBlox/quickblox-ios-sdk/downloads).

## Documentation

* [Project page on QuickBlox developers section](http://quickblox.com/developers/IOS)
* [Framework reference in AppleDoc format](http://sdk.quickblox.com/ios/)

## Oh, please, please show me the code

iOS SDK is really simple to use. Just in few minutes you can power your mobile app with huge amount of awesome functions to store, pass and represent your data. 

### 1. Get app credentials

* [How to get app credentials](http://quickblox.com/developers/Getting_application_credentials)

### 2. Create new iOS project
### 3. Add [framework](https://github.com/QuickBlox/quickblox-ios-sdk/tree/master/Framework) to project, see [this tutorial](http://quickblox.com/developers/IOS-how-to-connect-Quickblox-framework)
### 4. Make QuickBlox API calls

The common way to interact with QuickBlox can be presented with following sequence of actions:

1. [Initialize framework with application credentials](#initialize-framework-with-application-credentials)
2. [Create session](#create-session)
3. [Login with existing user or register new one](#register-login)
4. [Perform actions with any QuickBlox data entities (users, locations, files, custom objects, pushes etc.)](#perform-actions)

#### 4.1 Initialize framework with application credentials
#initialize-framework-with-application-credentials

```objectivec
[QBSettings setApplicationID:92];
[QBSettings setAuthorizationKey:@"wJHdOcQSxXQGWx5"];
[QBSettings setAuthorizationSecret:@"BTFsj7Rtt27DAmT"];
```

#### 4.2. Create session
#create-session

```objectivec
[QBAuth createSessionWithDelegate:self];

- (void)completedWithResult:(Result *)result{
    if(result.success && [result isKindOfClass:QBAAuthSessionCreationResult.class]){
        // Success, do something
    }
}
```

#### 4.3. Register/login
#register-login

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

#### 4.4. Perform actions
#perform-actions

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

iOS Framework provides following services to interact with QuickBlox functions (each service is represented by model with suite of static methods):

* QBAuth
* QBUsers
* QBCustomObjects
* QBLocation
* QBContent
* QBRatings
* QBMessages
* QBChat

## See also

* [QuickBlox REST API](http://quickblox.com/developers/Overview)