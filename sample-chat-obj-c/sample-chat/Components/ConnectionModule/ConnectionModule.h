//
//  ConnectionModule.h
//  sample-chat
//
//  Created by Injoit on 06.10.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Availability.h>
#import <SystemConfiguration/SystemConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AuthorizationAction)(void);
typedef void(^ConnectionAction)(void);
typedef void(^DisconnectionAction)(BOOL lostNetwork);


/// The module is responsible for automatic connection establishment with QuickBlox.
///
/// The connection depends on the application state and call activity.
/// The establishing connection process can start from the authorization if the "QBSession" token was expired.
@interface ConnectionModule : NSObject

/// Determining the connection state.
///
/// Calling this property starts the connection process when it's not established.
@property (nonatomic, assign, readonly) BOOL established;
/// The authorization process running.
@property (nonatomic, assign, readonly) BOOL isProcessing;
/// Determining the "QBSession" token state.
@property (nonatomic, assign, readonly) BOOL tokenHasExpired;

/// Called when authorization complete.
@property (nonatomic, readwrite, copy, nullable) AuthorizationAction onAuthorize;
/// Called when the connection was established or re-established.
@property (nonatomic, readwrite, copy, nullable) ConnectionAction onConnect;
/// Called when connection lost.
@property (nonatomic, readwrite, copy, nullable) DisconnectionAction onDisconnect;

/// Activating the automatic connection and disconnection process when the application state change.
///
/// Calling this method starts the connection process when it's not established.
- (void)activateAutomaticMode;
/// Prevents breaking connection when the application state change.
- (void)activateCallMode;
/// Break connection when application state is inactive.
- (void)deactivateCallMode;
/// Stop trying connection automatically.
- (void)deactivateAutomaticMode;
/// Establishes a connection with the Quickblox.
- (void)establishConnection;
/// Disconnects and unauthorize from the Quickblox.
- (void)breakConnectionWithCompletion:(nonnull void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END