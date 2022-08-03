//
//  CallInfo.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 21.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallParticipant.h"
#import "CallHelper.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChangedStateHandler)(CallParticipant *participant);
typedef void(^ChangedBitrateHandler)(NSNumber *ID, NSString *statsString);
typedef void(^UpdatedParticipantHandler)(NSNumber *ID, NSString *fullName);
typedef void(^CallHangUpAction)(NSString *callId);

@interface CallInfo : NSObject

@property (nullable, nonatomic, readwrite, copy) UpdatedParticipantHandler onUpdatedParticipant;
@property (nullable, nonatomic, readwrite, copy) ChangedStateHandler onChangedState;
@property (nullable, nonatomic, readwrite, copy) ChangedBitrateHandler onChangedBitrate;

@property (nonatomic, strong, readonly) NSString *callId;
/// Call participants, including the current user
@property (nonatomic, strong, readonly) NSArray<CallParticipant *> *participants;
/// Call participants, excluding the current user
@property (nonatomic, strong, readonly) NSArray<CallParticipant *> *interlocutors;
/// The current user id.
@property (nonatomic, strong, readonly) NSNumber *localParticipantId;

@property (nonatomic, assign, readonly) CallDirection direction;

/// The key is a user id and the value is a user name.
+ (CallInfo *)callInfoWithCallID:(NSString *)callId members:(NSDictionary<NSNumber *, NSString *>*)members direction:(CallDirection)direction;

- (CallParticipant * _Nullable)participantWithId:(NSNumber *)userId;

/// The key is a user id and the value is a user name.
- (void)updateWithMembers:(NSDictionary<NSNumber *, NSString *>*)members;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
