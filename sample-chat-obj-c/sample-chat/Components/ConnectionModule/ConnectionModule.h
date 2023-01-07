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

@class ConnectionModule;

@protocol ConnectionModuleDelegate <NSObject>
@optional
- (void)connectionModuleWillConnect:(ConnectionModule *)connectionModule;
- (void)connectionModuleDidConnect:(ConnectionModule *)connectionModule;
- (void)connectionModuleDidNotConnect:(ConnectionModule *)connectionModule withError:(NSError*)error;
- (void)connectionModuleWillReconnect:(ConnectionModule *)connectionModule;
- (void)connectionModuleDidReconnect:(ConnectionModule *)connectionModule;
- (void)connectionModuleTokenHasExpired:(ConnectionModule *)connectionModule;

@end

/// The module is responsible for automatic connection establishment with QuickBlox.
///
/// The connection depends on the application state and call activity.
/// The establishing connection process can start from the authorization if the "QBSession" token was expired.
@interface ConnectionModule : NSObject
@property (nonatomic, weak) id <ConnectionModuleDelegate> delegate;
/// Determining the connection state.
///
/// Calling this property starts the connection process when it's not established.
@property (nonatomic, assign, readonly) BOOL established;

/// Activating the automatic connection and disconnection process when the application state change.
///
/// Calling this method starts the connection process when it's not established.
- (void)activateAutomaticMode;
/// Stop trying connection automatically.
- (void)deactivateAutomaticMode;
/// Establishes a connection with the Quickblox.
- (void)establish;
/// Disconnects and unauthorize from the Quickblox.
- (void)breakConnectionWithCompletion:(nonnull void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
