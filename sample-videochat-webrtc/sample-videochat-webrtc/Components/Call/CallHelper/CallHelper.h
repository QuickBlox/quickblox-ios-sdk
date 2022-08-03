//
//  CallHelper.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 20.07.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallKitManager.h"

@class CallInfo;
@class MediaListener;
@class MediaController;
@class CallHelper;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CallDirection) {
    CallDirectionIncoming,
    CallDirectionOutgoing
};

typedef void(^CallMuteAction)(BOOL enable);

@protocol CallHelperDelegate <NSObject>

/// @param members: The call participants without a current user. The key is a user id and the value is a user name.
- (void)helper:(CallHelper *)helper
didRegisterCall:(NSString *)callId
 mediaListener:(MediaListener *)mediaListener
mediaController:(MediaController *)mediaController
     direction:(CallDirection)direction
       members:(NSDictionary<NSNumber *, NSString *>*)members
      hasVideo:(BOOL)hasVideo;

- (void)helper:(CallHelper *)helper didAcceptCall:(NSString *)callId;

- (void)helper:(CallHelper *)helper didUnregisterCall:(NSString *)callId;

@end

/// The CallHelper class provides creating, configuring, sending, receiving and processing video and audio calls.
/// Sends VoIP notifications.
/// Establishes a connection with the call members.
/// Setups the CallKit outgoing / incoming call.
@interface CallHelper : NSObject

@property (nonatomic, weak) id<CallHelperDelegate> delegate;

/// Active call id
@property (nonatomic, strong, readonly) NSString *registeredCallId;

- (BOOL)callReceivedWithSessionId:(NSString *)sessionID;

/// incoming Call
/// @param payload NSDictionary object with incoming call parameters
/// @param completion
///
/// Prepare an incoming call with its parameters. Setups the CallKit incoming call.
- (void)registerCallWithPayload:(NSDictionary *)payload
                     completion:(nonnull void (^)(void))completion;

/// Outgoing call execution method
/// @param members  NSDictionary object where key user ID and username value
/// @param hasVideo BOOL value describing that can be received video data
/// @param userInfo outgoing call meta parameters
///
/// Prepare an outgoing call with the members and its media type, forms and sends a Voip Push so that the callee can receive a call in the background.
/// Setups the CallKit outgoing  call.
- (void)registerCallWithMembers:(NSDictionary<NSNumber *, NSString *>*)members
                       hasVideo:(BOOL)hasVideo;

/// End call
/// @param callId NSString object represents session ID
/// @param userInfo Call meta parameters
///
/// Prepare the call to end
- (void)unregisterCall:(NSString *)callId
              userInfo:(NSDictionary<NSString *, NSString *>* _Nullable)userInfo;

/// Update Call
/// @param callId NSString object represents session ID
/// @param title NSString object represents localizedCallerName for CallKit
///
/// Called to update the caller name that is displayed on the call screen of CallKit
- (void)updateCall:(NSString *)callId title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
