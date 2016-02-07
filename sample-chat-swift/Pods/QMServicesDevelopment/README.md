**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [QMServices](#qmservices)
- [Features](#features)
- [Requirements](#requirements)
- [Dependencies](#dependencies)
- [Installation](#installation)
	- [1. Cocoapods](#1-cocoapods)
	- [2. Using an Xcode subproject](#2-using-an-xcode-subproject)
		- [Bundle generation](#bundle-generation)
- [Architecture](#architecture)
- [Getting started](#getting-started)
	- [Service Manager](#service-manager)
	- [Authentication](#authentication)
		- [Login](#login)
		- [Logout](#logout)
	- [Fetching chat dialogs](#fetching-chat-dialogs)
	- [Fetching chat messages](#fetching-chat-messages)
	- [Sending message](#sending-message)
	- [Fetching users](#fetching-users)
	- [Subclass of QMServicesManager example](#qmservices-example)
	- [QMAuthService](#qmauthservice)
		- [QMAuthService + Bolts](#qmauthservice--bolts)
	- [QMChatService](#qmauthservice)
		- [QMChatService + Bolts](#qmchatservice--bolts)
		- [QMDialogsMemoryStorage](#qmdialogsmemorystorage)
		- [QMMessagesMemoryStorage](#qmmessagesmemorystorage)
		- [QMChatAttachmentService](#qmchatattachmentservice)
	- [QMContactListService](#qmcontactlistservice)
		- [QMContactListMemoryStorage](#qmcontactlistmemorystorage)
	- [QMUsersService](#qmusersservice)
		- [QMUsersMemoryStorage](#qmusersmemorystorage)
			- [Add users](#add-users)
			- [Get users](#get-users)
			- [Search and Exclude](#search-and-exclude)
- [Documentation](#documentation)
- [License](#license)

# QMServices

Easy-to-use services for Quickblox SDK, for speeding up development of iOS chat applications.

# Features

* High level API for Chat features including authentication service for logging to Quickblox REST and XMPP
* Inbox persistent storage for messages, dialogs and users
* Inbox memory storage for messages, dialogs and users
* Bolts version of all methods. See [Bolts-iOS](https://github.com/BoltsFramework/Bolts-iOS "Bolts-iOS"") for more information.

# Requirements

- Xcode 6+
- ARC
- Quickblox iOS SDK
- Bolts-iOS

# Dependencies

- [Quickblox](https://github.com/QuickBlox/quickblox-ios-sdk 'Quickblox iOS SDK') SDK 2.5+
- [Bolts](https://github.com/BoltsFramework/Bolts-iOS 'Bolts-iOS') 1.5.0+

# Installation

There are several ways to add **QMServices** to your project. They are described below:

## 1. Cocoapods

You can install **QMServices** using Cocoapods just by adding following line in your Podfile:

```
pod 'QMServices'
```

## 2. Using an Xcode subproject

Xcode sub-projects allow your project to use and build QMServices as an implicit dependency.

Add QMServices to your project as a Git submodule:

```
$ cd MyXcodeProjectFolder
$ git submodule add https://github.com/QuickBlox/q-municate-services-ios.git Vendor/QMServices
$ git commit -m "Added QMServices submodule"
```

This will add QMServices as a submodule and download Bolts as dependency.
Drag `Vendor/QMServices/QMServices.xcodeproj ` into your existing Xcode project.

Navigate to your project's settings, then select the target you wish to add QMServices to.

Navigate to **Build Settings**, then search for **Header Search Paths** and double-click it to edit

Add a new item using **+**: `"$(SRCROOT)/Vendor/QMServices"` and ensure that it is set to *recursive*

Navigate to **Build Settings**, then search for **Framework Search Paths** and double-click it to edit

Add a new item using **+**: `"$(SRCROOT)/Vendor/QMServices/Frameworks"`

> ** NOTE**: By default, *QMServices* subprojects reference Quickblox and Bolts frameworks at `../Frameworks`.
> To change the path, you need to open Quickblox.xcconfig file and replace `../Frameworks` with your path to the Quickblox.framework and Bolts.framework.

> ** NOTE** Please be aware that if you've set Xcode's **Link Frameworks Automatically** to **No** then you may need to add the Quickblox.framework, CoreData.framework to your project on iOS, as UIKit does not include Core Data by default. On OS X, Cocoa includes Core Data.

Now navigate to QMServices.xcodeproj subproject, open **Build Settings**, search for **Framework Search Paths** and locate Quickblox and Bolts frameworks folder there.
Remember, that you have to link *QMServices* in **Target Dependencies** and *libQMServices.a* in **Link Binary with Libraries**.
Don't forget to add Quickblox and Bolts frameworks to your project.

### Bundle generation
**NOTE:** You can skip this step if you do not use dialogs, messages and users memory and disc storage.

Bundle allows to pass .xcdatamodel file together with static library so it is required for **QMChatCache** and **QMContactListCache** projects.

To generate bundle for contact list you need to open **QMServices** project, navigate to Cache folder and select **QMContactListCache.xcodeproj**. Open project folder - you will see red **QMContactListCacheModel.bundle**. To create it select scheme **QMContactListCacheModel** and run it. After successful build **QMContactListCacheModel.bundle** color will change to black and you will be able to copy it to the project that uses **QMServices**. Include this bundle in your project.

To generate bundle for dialogs and messages you need to open **QMServices** project, navigate to Cache folder and select **QMChatCache.xcodeproj**. Open project folder - you will see red **QMChatCacheModel.bundle**. To create it select scheme **QMChatCacheModel** and run it. After successful build **QMChatCacheModel.bundle`** color will change to black and you will be able to copy it to the project that uses **QMServices**. Include this bundle in your project.

# Architecture

QMServices contains:

* **QMAuthService**
* **QMChatService**
* **QMContactListService**
* **QMUsersService**


They all inherited from **QMBaseService**.
To support CoreData caching you can use **QMContactListCache**, **QMChatCache** and **QMUsersCache**, which are inherited from **QMDBStorage**. Of course you could use your own database storage - just need to implement **QMChatServiceDelegate**, **QMContactListServiceDelegate** or **QMUsersServiceDelegate** depending on your needs.

# Getting started
Add **#import \<QMServices.h\>** to your apps *.pch* file.

## Service Manager

To start using services you could either use existing **QMServicesManager** class or create a subclass from it.
Detailed explanation of the **QMServicesManager** class is below.

**QMServicesManager** has 2 functions - user login(login to REST API, chat)/logout(Logging out from chat, REST API, clearing persistent and memory cache) and establishing connection between **QMChatCache** and **QMChatService** to enable storing dialogs and messages data on disc.

Here is **QMServicesManager.h**:

```objective-c
@interface QMServicesManager : NSObject <QMServiceManagerProtocol, QMChatServiceCacheDataSource, QMChatServiceDelegate, QMChatConnectionDelegate>

+ (instancetype)instance;

- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL success, NSString *errorMessage))completion;
- (void)logoutWithCompletion:(dispatch_block_t)completion;

@property (nonatomic, readonly) QMAuthService* authService;
@property (nonatomic, readonly) QMChatService* chatService;

@end
```

And extension in **QMServicesManager.m**:

```objective-c
@interface QMServicesManager ()

@property (nonatomic, strong) QMAuthService* authService;
@property (nonatomic, strong) QMChatService* chatService;

@property (nonatomic, strong) dispatch_group_t logoutGroup;

@end
```

In ``init`` method, services and cache are initialised.

```objective-c
- (instancetype)init {
	self = [super init];
	if (self) {
		[QMChatCache setupDBWithStoreNamed:@"sample-cache"];
        	[QMChatCache instance].messagesLimitPerDialog = 10;

		_authService = [[QMAuthService alloc] initWithServiceManager:self];
		_chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
        	[_chatService addDelegate:self];
        	_logoutGroup = dispatch_group_create();
	}
	return self;
}
```

* Cache setup (You could skip it if you don't need persistent storage).

	* Initiates Core Data database for dialog and messages:

	```objective-c
	[QMChatCache setupDBWithStoreNamed:@"sample-cache"];
	```

* Services setup

	* Authentication service:
	
	```objective-c
	_authService = [[QMAuthService alloc] initWithServiceManager:self];
	```
	
	* Chat service (responsible for establishing chat connection and responding to chat events (message, presences and so on)):

	```objective-c
	_chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
	```
	
Also you have to implement **QMServiceManagerProtocol** methods:

```objective-c
- (void)handleErrorResponse:(QBResponse *)response {
	// handle error response from services here
}

- (BOOL)isAutorized {
	return self.authService.isAuthorized;
}

- (QBUUser *)currentUser {
	return [QBSession currentSession].currentUser;
}
```

To implement chat messages and dialogs caching you should implement following methods from **QMChatServiceDelegate** protocol:

```objective-c
- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
	[QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
	[QMChatCache.instance insertOrUpdateDialogs:chatDialogs completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
	[QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
	[QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [QMChatCache.instance deleteDialogWithID:chatDialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService  didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
	[QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialog.ID completion:nil];
	[QMChatCache.instance insertOrUpdateDialog:dialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    [[QMChatCache instance] insertOrUpdateDialog:chatDialog completion:nil];
}
```

Also for prefetching initial dialogs and messages you have to implement **QMChatServiceCacheDataSource** protocol:

```objective-c
- (void)cachedDialogs:(QMCacheCollection)block {
	[QMChatCache.instance dialogsSortedBy:CDDialogAttributes.lastMessageDate ascending:YES completion:^(NSArray *dialogs) {
		block(dialogs);
	}];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
	[QMChatCache.instance messagesWithDialogId:dialogID sortedBy:CDMessageAttributes.messageID ascending:YES completion:^(NSArray *array) {
		block(array);
	}];
}
```

## Authentication

We encourage to use automatic session creation, to simplify communication with backend:

```objective-c
[QBConnection setAutoCreateSessionEnabled:YES];
```

### Login

This method logins user to Quickblox REST API backend and to the Quickblox Chat backend. Also it automatically tries to join to all cached group dialogs - to immediately receive incomming messages.

```objective-c
- (void)logInWithUser:(QBUUser *)user
		   completion:(void (^)(BOOL success, NSString *errorMessage))completion
{
	[self.authService logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
		if (response.error != nil) {
			if (completion != nil) {
				completion(NO, response.error.error.localizedDescription);
			}
			return;
		}
		
        __weak typeof(self) weakSelf = self;
        [weakSelf.chatService connectWithCompletionBlock:^(NSError * _Nullable error) {
            //
            __typeof(self) strongSelf = weakSelf;
            
            [strongSelf.chatService loadCachedDialogsWithCompletion:^{
                NSArray* dialogs = [strongSelf.chatService.dialogsMemoryStorage unsortedDialogs];
                for (QBChatDialog* dialog in dialogs) {
                    if (dialog.type != QBChatDialogTypePrivate) {
                        [strongSelf.chatService joinToGroupDialog:dialog completion:^(NSError * _Nullable error) {
                            //
                            if (error != nil) {
                                NSLog(@"Join error: %@", error.localizedDescription);
                            }
                        }];
                    }
                }
                
                if (completion != nil) {
                    completion(error == nil, error.localizedDescription);
                }
                
            }];
        }];
	}];
}


```

Example of usage:

```objective-c
    // Logging in to Quickblox REST API and chat.
    [QMServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
        	// Handle success login
        } else {
            	// Handle error with error message
        }
    }];
```

### Logout

```objective-c
- (void)logoutWithCompletion:(dispatch_block_t)completion
{
    if ([QBSession currentSession].currentUser != nil) {
        __weak typeof(self)weakSelf = self;    
        
        dispatch_group_enter(self.logoutGroup);
        [self.authService logOut:^(QBResponse *response) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf.chatService disconnectWithCompletionBlock:nil];
            [strongSelf.chatService free];
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_enter(self.logoutGroup);
        [[QMChatCache instance] deleteAllDialogs:^{
            __typeof(self) strongSelf = weakSelf;
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_enter(self.logoutGroup);
        [[QMChatCache instance] deleteAllMessages:^{
            __typeof(self) strongSelf = weakSelf;
            dispatch_group_leave(strongSelf.logoutGroup);
        }];
        
        dispatch_group_notify(self.logoutGroup, dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    } else {
        if (completion) {
            completion();
        }
    }
}
```

Example of usage:

```objective-c
    [[QMServicesManager instance] logoutWithCompletion:^{
        // Handle logout
    }];
```

## Fetching chat dialogs

Load all dialogs from REST API:

Extended request parameters could be taken from http://quickblox.com/developers/SimpleSample-chat_users-ios#Filters.

```objective-c

[QMServicesManager.instance.chatService allDialogsWithPageLimit:100 extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
	// reload UI, this block is called when page is loaded
} completion:^(QBResponse *response) {
	// loading finished, all dialogs fetched
}];
```

These dialogs are automatically stored in **QMDialogsMemoryStorage** class.

## Fetching chat messages

Fetching messages from REST API history:

```objective-c
[QMServicesManager instance].chatService messagesWithChatDialogID:@"53fdc87fe4b0f91d92fbb27e" completion:^(QBResponse *response, NSArray *messages) {
	// update UI, handle messages
}];
```

These message are automatically stored in **QMMessagesMemoryStorage** class.

## Sending message

Send message to dialog:

```objective-c

QBChatMessage *message = [QBChatMessage message];
message.text = @"Awesome text";
message.senderID = 2308497;

[[QMServicesManager instance].chatService sendMessage:message type:QMMessageTypeText toDialogId:@"53fdc87fe4b0f91d92fbb27e" saveToHistory:YES saveToStorage:YES completion:nil];
```

Message is automatically added to **QMMessagesMemoryStorage** class.

## Fetching users


```objective-c
[[[QMServicesManager instance].usersService getUsersWithIDs:@[@(2308497), @(2308498)]] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
        if (task.error == nil) {
            // handle users
        }
        return nil;
}];
```

Users are automatically stored in **QMUsersMemoryStorage** class.

## Subclass of QMServicesManager example

This example adds additional functionality - storing of users in contact list cache, error handling, storing currently opened dialog identifier.

Header file:

```objective-c
@interface ServicesManager : QMServicesManager <QMContactListServiceCacheDataSource>

// Replaces with any users service you are already using or going to use
@property (nonatomic, readonly) UsersService* usersService;

@property (nonatomic, strong) NSString* currentDialogID;

@end

```

Implementation file:

```objective-c
@interface ServicesManager ()

@property (nonatomic, strong) QMContactListService* contactListService;

@end

@implementation ServicesManager

- (instancetype)init {
	self = [super init];
    
	if (self) {
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
		_contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
		// Replace with any users service you are already using or going to use
		_usersService = [[UsersService alloc] initWithContactListService:_contactListService];
	}
    
	return self;
}

- (void)showNotificationForMessage:(QBChatMessage *)message inDialogID:(NSString *)dialogID
{
    if ([self.currentDialogID isEqualToString:dialogID]) return;
    
    if (message.senderID == self.currentUser.ID) return;
    
    NSString* dialogName = @"New message";
    
    QBChatDialog* dialog = [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    
    if (dialog.type != QBChatDialogTypePrivate) {
        dialogName = dialog.name;
    } else {
        QBUUser* user = [[StorageManager instance] userByID:dialog.recipientID];
        if (user != nil) {
            dialogName = user.login;
        }
    }
    
    // Display notification UI
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    [super handleErrorResponse:response];
    
    if (![self isAutorized]) return;
	NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
	errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
	
	if( response.status == 502 ) { // bad gateway, server error
		errorMessage = @"Bad Gateway, please try again";
	}
	else if( response.status == 0 ) { // bad gateway, server error
		errorMessage = @"Connection network error, please try again";
	}
    
    // Display notification UI
}

#pragma mark QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [super chatService:chatService didAddMessageToMemoryStorage:message forDialogID:dialogID];
    
    [self showNotificationForMessage:message inDialogID:dialogID];
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedUsers:(QMCacheCollection)block {
	[QMContactListCache.instance usersSortedBy:@"id" ascending:YES completion:block];
}

- (void)cachedContactListItems:(QMCacheCollection)block {
	[QMContactListCache.instance contactListItems:block];
}

@end
```

## QMAuthService

This class is responsible for authentication operations.

Current user authorisation status:

```objective-c

@property (assign, nonatomic, readonly) BOOL isAuthorized;

```

Sign up user and log's in to Quickblox.

```objective-c

- (QBRequest *)signUpAndLoginWithUser:(QBUUser *)user completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

```

Login user to Quickblox.

```objective-c

- (QBRequest *)logInWithUser:(QBUUser *)user completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

```

Login with facebook session token.

```objective-c

- (QBRequest *)logInWithFacebookSessionToken:(NSString *)sessionToken completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

```

Logout user from Quickblox.

```objective-c

- (QBRequest *)logInWithFacebookSessionToken:(NSString *)sessionToken completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion;

```

### QMAuthService + Bolts 

QMAuthService also has all methods implemented using BFTasks.

Sign up user and log's in to Quickblox using Bolts.

```objective-c

- (BFTask *)signUpAndLoginWithUser:(QBUUser *)user;

```

Login user to Quickblox using Bolts.

```objective-c

- (BFTask *)loginWithUser:(QBUUser *)user;

```

Login with facebook session token using Bolts.

```objective-c

- (BFTask *)loginWithFacebookSessionToken:(NSString *)sessionToken;

```

Logout user from Quickblox using Bolts.

```objective-c

- (BFTask *)logout;

```

## QMChatService

This class is responsible for operation with messages and dialogs.

Connect user to Quickblox chat.

```objective-c

- (void)connectWithCompletionBlock:(QBChatCompletionBlock)completion;

```

Disconnect user from Quickblox chat.

```objective-c

- (void)disconnectWithCompletionBlock:(QBChatCompletionBlock)completion;

```

Automatically send presences after logging in to Quickblox chat.

```objective-c

@property (nonatomic, assign) BOOL automaticallySendPresences;

```

Time interval for sending preseneces - default value 45 seconds.

```objective-c

@property (nonatomic, assign) NSTimeInterval presenceTimerInterval;

```

Join user to group dialog.

```objective-c

- (void)joinToGroupDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion;

```

Create group chat dialog with occupants on Quickblox.

```objective-c

- (void)createGroupChatDialogWithName:(NSString *)name photo:(NSString *)photo occupants:(NSArray *)occupants
completion:(void(^)(QBResponse *response, QBChatDialog *createdDialog))completion;

```

Create private chat dialog with opponent on Quickblox.

```objective-c

- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent
completion:(void(^)(QBResponse *response, QBChatDialog *createdDialog))completion;

```

Change dialog name.

```objective-c

- (void)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog
completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;

```

Change dialog avatar.

```objective-c

- (void)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog
completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;

```

Add occupants to dialog.

``` objective-c

- (void)joinOccupantsWithIDs:(NSArray *)ids toChatDialog:(QBChatDialog *)chatDialog
completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;


```


Deletes dialog on service and in cache.

```objective-c

- (void)deleteDialogWithID:(NSString *)dialogId
completion:(void(^)(QBResponse *response))completion;

```

Recursively fetch all dialogs from Quickblox.

```objective-c

- (void)allDialogsWithPageLimit:(NSUInteger)limit
				extendedRequest:(NSDictionary *)extendedRequest
				 iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))interationBlock
					 completion:(void(^)(QBResponse *response))completion;
```

Send system message to users about adding to dialog with dialog inside.

```objective-c

- (void)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                  toUsersIDs:(NSArray *)usersIDs
                                  completion:(QBChatCompletionBlock)completion;

```

Send message about updated dialog with dialog inside and notification.

```objective-c

- (void)sendMessageAboutUpdateDialog:(QBChatDialog *)updatedDialog
                withNotificationText:(NSString *)notificationText
                    customParameters:(NSDictionary *)customParameters
                          completion:(QBChatCompletionBlock)completion;

```

Send message about accepting or rejecting contact requst.

```objective-c

- (void)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                   toOpponentID:(NSUInteger)opponentID
                                     completion:(QBChatCompletionBlock)completion;

```

Sending notification message about adding occupants to specific dialog.

```objective-c

- (void)sendNotificationMessageAboutAddingOccupants:(NSArray *)occupantsIDs
                                           toDialog:(QBChatDialog *)chatDialog
                               withNotificationText:(NSString *)notificationText
                                         completion:(QBChatCompletionBlock)completion;
                                         
```

Sending notification message about leaving dialog.

```objective-c

- (void)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog
                             withNotificationText:(NSString *)notificationText
                                       completion:(QBChatCompletionBlock)completion;
                                         
```

Sending notification message about changing dialog photo.

```objective-c

- (void)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog
                                   withNotificationText:(NSString *)notificationText
                                             completion:(QBChatCompletionBlock)completion;
                                         
```

Sending notification message about changing dialog name.

```objective-c

- (void)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog
                                  withNotificationText:(NSString *)notificationText
                                            completion:(QBChatCompletionBlock)completion;
                                         
```

Fetches 100 messages starting from latest message in cache.

```objective-c

- (void)messagesWithChatDialogID:(NSString *)chatDialogID completion:(void(^)(QBResponse *response, NSArray *messages))completion;

```

Fetches 100 messages that are older than oldest message in cache.

```objective-c

- (BFTask <NSArray <QBChatMessage *> *> *)loadEarlierMessagesWithChatDialogID:(NSString *)chatDialogID;

```

Fetch dialog with dialog identifier.

```objective-c

- (void)fetchDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion;

```

Load dialog with dialog identifier from Quickblox server and save to local storage.

```objective-c

- (void)loadDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *loadedDialog))completion;

```

Fetch dialogs updated from date.

```objective-c

- (void)fetchDialogsUpdatedFromDate:(NSDate *)date
 					   andPageLimit:(NSUInteger)limit
 					 iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))iteration
 					completionBlock:(void (^)(QBResponse *response))completion;

```

Send message to dialog.

```objective-c

- (void)sendMessage:(QBChatMessage *)message
		   toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion;

```

Send attachment message to dialog.

```objective-c

- (void)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                     toDialog:(QBChatDialog *)dialog
          withAttachmentImage:(UIImage *)image
                   completion:(QBChatCompletionBlock)completion;

```

Mark message as delivered.

```objective-c

- (void)markMessageAsDelivered:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion;

```

Mark messages as delivered.

```objective-c

- (void)markMessagesAsDelivered:(NSArray<QBChatMessage *> *)messages completion:(QBChatCompletionBlock)completion;

```

Send read status for message and update unreadMessageCount for dialog in storage.

```objective-c

- (void)readMessage:(QBChatMessage *)message completion:(QBChatCompletionBlock)completion;

```

Send read status for messages and update unreadMessageCount for dialog in storage.

```objective-c

- (void)readMessages:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID completion:(QBChatCompletionBlock)completion;

```

### QMChatService + Bolts 

QMChatService also has all methods implemented using BFTasks.

Connect user to Quickblox chat using Bolts.

```objective-c

- (BFTask *)connect;

```

Disconnect user from Quickblox chat using Bolts.

```objective-c

- (BFTask *)disconnect;

```

Join user to group dialog using Bolts.

```objective-c

- (BFTask *)joinToGroupDialog:(QBChatDialog *)dialog;

```

Create group chat dialog with occupants on Quickblox using Bolts.

```objective-c

- (BFTask *)createGroupChatDialogWithName:(NSString *)name photo:(NSString *)photo occupants:(NSArray *)occupants;

```

Create private chat dialog with opponent on Quickblox using Bolts.

```objective-c

- (BFTask *)createPrivateChatDialogWithOpponent:(QBUUser *)opponent;

```

Change dialog name using Bolts.

```objective-c

- (BFTask *)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog;

```

Change dialog avatar using Bolts.

```objective-c

- (BFTask *)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog;

```

Add occupants to dialog using Bolts.

``` objective-c

- (BFTask *)joinOccupantsWithIDs:(NSArray *)ids toChatDialog:(QBChatDialog *)chatDialog;

```

Deletes dialog on service and in cache using Bolts.

```objective-c

- (BFTask *)deleteDialogWithID:(NSString *)dialogID;

```

Recursively fetch all dialogs from Quickblox using Bolts.

```objective-c

- (BFTask *)allDialogsWithPageLimit:(NSUInteger)limit
                    extendedRequest:(NSDictionary *)extendedRequest
                     iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))interationBlock;

```

Send system message to users about adding to dialog with dialog inside using Bolts.

```objective-c

- (BFTask *)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                      toUsersIDs:(NSArray *)usersIDs;

```

Send message about accepting or rejecting contact requst using Bolts.

```objective-c

- (BFTask *)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                       toOpponentID:(NSUInteger)opponentID;

```

Sending notification message about adding occupants to specific dialog using Bolts.

```objective-c

- (BFTask *)sendNotificationMessageAboutAddingOccupants:(NSArray *)occupantsIDs
                                               toDialog:(QBChatDialog *)chatDialog
                                   withNotificationText:(NSString *)notificationText;
                                         
```

Sending notification message about leaving dialog using Bolts.

```objective-c

- (BFTask *)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog
                                 withNotificationText:(NSString *)notificationText;
                                         
```

Sending notification message about changing dialog photo using Bolts.

```objective-c

- (BFTask *)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog
                                       withNotificationText:(NSString *)notificationText;
                                         
```

Sending notification message about changing dialog name using Bolts.

```objective-c

- (BFTask *)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog
                                      withNotificationText:(NSString *)notificationText;
                                         
```

Fetches messages with chat dialog ID using Bolts.

```objective-c

- (BFTask *)messagesWithChatDialogID:(NSString *)chatDialogID;

```

Fetch dialog with dialog identifier using Bolts.

```objective-c

- (BFTask *)fetchDialogWithID:(NSString *)dialogID;

```

Load dialog with dialog identifier from Quickblox server and save to local storage using Bolts.

```objective-c

- (BFTask *)loadDialogWithID:(NSString *)dialogID;

```

Fetch dialogs updated from date using Bolts.

```objective-c

- (BFTask *)fetchDialogsUpdatedFromDate:(NSDate *)date
                           andPageLimit:(NSUInteger)limit
                         iterationBlock:(void(^)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop))iteration;

```

Send message to dialog using Bolts.

```objective-c

- (BFTask *)sendMessage:(QBChatMessage *)message
               toDialog:(QBChatDialog *)dialog
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage;

```

Send attachment message to dialog using Bolts.

```objective-c

- (BFTask *)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                         toDialog:(QBChatDialog *)dialog
              withAttachmentImage:(UIImage *)image;

```

Mark message as delivered using Bolts.

```objective-c

- (BFTask *)markMessageAsDelivered:(QBChatMessage *)message;

```

Send read status for message and update unreadMessageCount for dialog in storage using Bolts.

```objective-c

- (BFTask *)readMessage:(QBChatMessage *)message;

```

### QMDialogsMemoryStorage

This class is responsible for in-memory dialogs storage.

Adds chat dialog and joins if chosen.

```objective-c

- (void)addChatDialog:(QBChatDialog *)chatDialog andJoin:(BOOL)join completion:(void(^)(QBChatDialog *addedDialog, NSError *error))completion;

```

Adds chat dialogs and joins.

```objective-c

- (void)addChatDialogs:(NSArray *)dialogs andJoin:(BOOL)join;

```

Deletes chat dialog.

```objective-c

- (void)deleteChatDialogWithID:(NSString *)chatDialogID;

```

Find dialog by identifier.

```objective-c

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;

```

Find private chat dialog with opponent ID.

```objective-c

- (QBChatDialog *)privateChatDialogWithOpponentID:(NSUInteger)opponentID;

```

Find unread dialogs.

```objective-c

- (NSArray *)unreadDialogs;

```

Fetch all dialogs.

```objective-c

- (NSArray *)unsortedDialogs;

```

Fetch all dialogs sorted by last message date.

```objective-c

- (NSArray *)dialogsSortByLastMessageDateWithAscending:(BOOL)ascending;

```

Fetch all dialogs sorted by updated at.

```objective-c

- (NSArray *)dialogsSortByUpdatedAtWithAscending:(BOOL)ascending;

```

Fetch dialogs with specified sort descriptors.

```objective-c

- (NSArray *)dialogsWithSortDescriptors:(NSArray *)descriptors;

```

### QMMessagesMemoryStorage

This class is responsible for in-memory messages storage.

Add message.

```objective-c

- (void)addMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

```

Add messages.

```objective-c

- (void)addMessages:(NSArray *)messages forDialogID:(NSString *)dialogID;

```

Replace all messages for dialog.

```objective-c

- (void)replaceMessages:(NSArray *)messages forDialogID:(NSString *)dialogID;

```

Update message.

```objective-c

- (void)updateMessage:(QBChatMessage *)message;

```

Fetch messages.

```objective-c

- (NSArray *)messagesWithDialogID:(NSString *)dialogID;

```

Delete messages for dialog.

```objective-c

- (void)deleteMessagesWithDialogID:(NSString *)dialogID;

```

Fetch message by identifier.

```objective-c

- (QBChatMessage *)messageWithID:(NSString *)messageID fromDialogID:(NSString *)dialogID;

```

Fetch last message.

```objective-c

- (QBChatMessage *)lastMessageFromDialogID:(NSString *)dialogID;

```

Checks if dialog has messages.

```objective-c

- (BOOL)isEmptyForDialogID:(NSString *)dialogID;

```

Fetch oldest(first) message.

```objective-c

- (QBChatMessage *)oldestMessageForDialogID:(NSString *)dialogID;

```

### QMChatAttachmentService

This class is responsible for attachment operations (sending, receiving, loading, saving).

Attachment status delegate:

```objective-c

@property (nonatomic, weak) id<QMChatAttachmentServiceDelegate> delegate;

```

Get attachment image. (Download from Quickblox or load from disc).

```objective-c

- (void)getImageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(void(^)(NSError *error, UIImage *image))completion;

```

## QMContactListService

This class is responsible for contact list operations.

Add user to contact list.

```objective-c

- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion;

```

Remove user from contact list.

```objective-c

- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

```

Accept contact request.

```objective-c

- (void)acceptContactRequest:(NSUInteger)userID completion:(void (^)(BOOL success))completion;

```

Reject contact request.

```objective-c

- (void)rejectContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

```

### QMContactListMemoryStorage

This class is responsible for in-memory contact list storage.

Update contact list memory storage.

```objective-c

- (void)updateWithContactList:(QBContactList *)contactList;

```

Update contact list memory storage with array of contact list items.

```objective-c

- (void)updateWithContactList:(QBContactList *)contactList;

```

Fetch contact list item.

```objective-c

- (QBContactListItem *)contactListItemWithUserID:(NSUInteger)userID;

```

Fetch user ids from contact list memory storage.

```objective-c

- (NSArray *)userIDsFromContactList;

```

## QMUsersService

This class is responsible for operations with users and uses [BFTasks](https://github.com/BoltsFramework/Bolts-iOS "Bolts-iOS").

Load users to memory storage from disc cache.

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)loadFromCache;

```

Get user by id:

```objective-c

- (BFTask<QBUUser *> *)getUserWithID:(NSUInteger)userID;

```

Get users by ids:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithIDs:(NSArray<NSNumber *> *)usersIDs;

```

Get users by ids with extended pagination parameters:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithIDs:(NSArray<NSNumber *> *)usersIDs page:(QBGeneralResponsePage *)page;

```

Get users by emails:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithEmails:(NSArray<NSString *> *)emails;

```

Get users by emails with extended pagination parameters:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithEmails:(NSArray<NSString *> *)emails page:(QBGeneralResponsePage *)page;

```

Get users by facebook ids:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs;

```

Get users by facebook ids with extended pagination parameters:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs page:(QBGeneralResponsePage *)page;

```

Get users by logins:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithLogins:(NSArray<NSString *> *)logins;

```

Get users by logins with extended pagination parameters:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithLogins:(NSArray<NSString *> *)logins page:(QBGeneralResponsePage *)page;

```

Search for users by full name:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithFullName:(NSString *)searchText;

```

Search for users by full name with extended pagination parameters:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithFullName:(NSString *)searchText page:(QBGeneralResponsePage *)page;

```

Search for users by tags:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithTags:(NSArray<NSString *> *)tags;

```

Search for users by tags with extended pagination parameters:

```objective-c

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithTags:(NSArray<NSString *> *)tags page:(QBGeneralResponsePage *)page;

```

### QMUsersMemoryStorage

This class is responsible for in-memory users storage.

Delegate for getting UsersMemoryStorage user ids.

```objective-c

@property (weak, nonatomic) id <QMUsersMemoryStorageDelegate> delegate;

```

#### Add users

Add user to memory storage.

```objective-c

- (void)addUser:(QBUUser *)user;

```

Add users to memory storage.

```objective-c

- (void)addUsers:(NSArray *)users;

```

#### Get users

Get all users from memory storage without sorting.

```objective-c

- (NSArray *)unsortedUsers;

```

Get all users in memory storage sorted by key.

```objective-c

- (NSArray *)usersSortedByKey:(NSString *)key ascending:(BOOL)ascending;

```

Get all contacts in memory storage sorted by key.

```objective-c

- (NSArray *)contactsSortedByKey:(NSString *)key ascending:(BOOL)ascending;

```

Get users with ids without some id.

```objective-c

- (NSArray *)usersWithIDs:(NSArray *)IDs withoutID:(NSUInteger)ID;

```

Get string created from users full names, separated by ",".

```objective-c

- (NSString *)joinedNamesbyUsers:(NSArray *)users;

```

Get user with user id.

```objective-c

- (QBUUser *)userWithID:(NSUInteger)userID;

```

Get users with user ids.

```objective-c

- (NSArray *)usersWithIDs:(NSArray *)ids;

```

Get users with user logins.

```objective-c

- (NSArray<QBUUser *> *)usersWithLogins:(NSArray<NSString *> *)logins;

```

Get users with user emails.

```objective-c

- (NSArray<QBUUser *> *)usersWithEmails:(NSArray<NSString *> *)emails;

```

Get users with user facebook ids.

```objective-c

- (NSArray<QBUUser *> *)usersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs;

```

#### Search and Exclude
Search for users excluding users with users ids. Result dictionary will contain an array of found users, and an array of not found search criteria (ids, logins, emails etc).

```objective-c

- (NSDictionary *)usersByExcludingUsersIDs:(NSArray<NSNumber *> *)ids;

```

Search for users excluding users with logins.

```objective-c

- (NSDictionary *)usersByExcludingLogins:(NSArray<NSString *> *)logins;

```

Search for users excluding users with email.

```objective-c

- (NSDictionary *)usersByExcludingEmails:(NSArray<NSString *> *)emails;

```

Search for users excluding users with facebook IDs.

```objective-c

- (NSDictionary *)usersByExcludingFacebookIDs:(NSArray<NSString *> *)facebookIDs;

```

# Documentation

For more information see our inline code documentation.

# License

See [LICENSE.txt](LICENSE.txt)
