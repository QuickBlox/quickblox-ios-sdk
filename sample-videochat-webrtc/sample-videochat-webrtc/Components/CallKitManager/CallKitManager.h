//
//  CallKitManager.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UsersDataSource;

NS_ASSUME_NONNULL_BEGIN

/**
 CallKitManager class interface.
 Used as manager of Apple CallKit.
 */
@interface CallKitManager : NSObject

/**
 Class singleton instance.
 */
@property (nonatomic, class, readonly) CallKitManager *instance;

/**
 UserDataSource instance to get users information from.
 */
@property (weak, nonatomic) UsersDataSource *usersDatasource;

/**
 Action on microphone mute using CallKit UI.
 */
@property (copy, nonatomic) dispatch_block_t onMicrophoneMuteAction;

/**
 Start Call with user IDs.
 
 @param userIDs user IDs to perform call with
 @param session session instance
 @param uuid call uuid
 
 @discussion Use this to perform outgoing call with specific user ids.
 
 @see QBRTCSession
 */

- (Boolean)isCallDidStarted;

- (void)startCallWithUserIDs:(NSArray <NSNumber *> *)userIDs session:(QBRTCSession *)session uuid:(NSUUID *)uuid;

/**
 End call with uuid.
 
 @param uuid uuid of call
 @param completion completion block
 */
- (void)endCallWithUUID:(NSUUID *)uuid completion:(nullable dispatch_block_t)completion;

/**
 Report incoming call with user IDs.
 
 @param userIDs user IDs of incoming call
 @param session session instance
 @param uuid call uuid
 @param onAcceptAction on call accept action
 @param completion completion block
 
 @discussion Use this to show incoming call screen.
 
 @see QBRTCSession
 */
- (void)reportIncomingCallWithUserIDs:(NSArray <NSNumber *> *)userIDs outCallerName:(NSString *)callerName session:(QBRTCSession *)session uuid:(NSUUID *)uuid onAcceptAction:(nullable dispatch_block_t)onAcceptAction completion:(void (^)(BOOL))completion;

/**
 Update outgoing call with connecting date
 
 @param uuid call uuid
 @param date connecting started date
 */
- (void)updateCallWithUUID:(NSUUID *)uuid connectingAtDate:(NSDate *)date;

/**
 Update outgoing call with connected date.
 
 @param uuid call uuid
 @param date connected date
 */
- (void)updateCallWithUUID:(NSUUID *)uuid connectedAtDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
