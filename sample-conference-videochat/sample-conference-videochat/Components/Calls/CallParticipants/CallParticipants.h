//
//  CallParticipants.h
//  sample-conference-videochat
//
//  Created by Injoit on 21.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallParticipant.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallParticipants : NSObject
@property (nonatomic, assign, readonly) NSUInteger count;
/// The current user id.
@property (nonatomic, assign, readonly) NSNumber *localId;
@property (nonatomic, strong, readonly) NSMutableArray<CallParticipant *>*participants;

/// The key is a user id and the value is a user name.

- (void)addParticipantWithId:(NSNumber *)userId fullName:(NSString *)fullName;
- (NSUInteger)participantIndexWithId:(NSNumber *)userId;
- (NSNumber *)participantIdWithIndex:(NSUInteger)index;
- (CallParticipant * _Nullable)participantWithId:(NSNumber *)userId;
- (CallParticipant * _Nullable)participantWithIndex:(NSUInteger)index;
- (void)removeParticipantWithId:(NSNumber *)userId;


- (UIView * _Nullable)videoViewWithIndex:(NSUInteger)index;
- (UIView * _Nullable)videoViewWithId:(NSNumber *)userId;
- (void)addVideView:(UIView *)view withId:(NSNumber *)userId;
- (void)removeVideViewWithId:(NSNumber *)userId;

@end

NS_ASSUME_NONNULL_END
