//
//  CallKit.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 26.05.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

typedef NS_ENUM(NSInteger, IncommingCallState) {
    IncommingCallStateValid,
    IncommingCallStateMissed,
    /// Some call data wrong or absent
    IncommingCallStateInvalid
};

@class CallKitInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol CallKitManagerDelegate;
@protocol CallKitManagerActionDelegate;

@interface CallKitManager : NSObject

@property (nonatomic, strong, readonly) NSUUID * _Nullable callUUID;

@property (nonatomic, weak) id<CallKitManagerDelegate> delegate;
@property (nonatomic, weak) id<CallKitManagerActionDelegate> actionDelegate;

- (void)reportIncomingCall:(NSString *)sessionId
                     title:(NSString *)title
                  hasVideo:(BOOL)hasVideo
                     state:(IncommingCallState)state
                completion:(void (^ _Nullable)(void))completion;
- (void)reportOutgoingCall:(NSString *)sessionId
                     title:(NSString *)title
                  hasVideo:(BOOL)hasVideo
                completion:(void (^ _Nullable)(void))completion;
- (void)reportEndCall:(NSString *)sessionId;
- (void)reportEndCall:(NSString *)sessionId reason:(CXCallEndedReason)reason;
- (void)reportAcceptCall:(NSString *)sessionId;
- (void)reportUpdateCall:(NSString *)sessionId
                   title:(NSString *)title;
- (void)muteAudio:(BOOL)mute call:(NSString *)sessionId;
@end

@protocol CallKitManagerDelegate <NSObject>

- (void)callKit:(CallKitManager *)callKit didTapAnswer:(NSString *)sessionId;
- (void)callKit:(CallKitManager *)callKit didTapRedject:(NSString *)sessionId;

/// external ending using "reportEndCall" methods
- (void)callKit:(CallKitManager *)callKit didEndCall:(NSString *)sessionId;

@end

@protocol CallKitManagerActionDelegate <NSObject>

- (void)callKit:(CallKitManager *)callKit didTapMute:(BOOL)isMuted;

@end

NS_ASSUME_NONNULL_END
