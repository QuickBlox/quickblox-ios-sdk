//
//  CallInfo.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 21.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallInfo.h"
#import "Profile.h"
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>

@interface CallInfo() <QBRTCClientDelegate>

/// Sorted participants ids.
@property (nonatomic, strong) NSArray<NSNumber *>*list;
/// The call participants details where the key is a user id.
@property (nonatomic, strong) NSDictionary<NSNumber *, CallParticipant *> *cache;
@property (nonatomic, strong) Profile *profile;
@property (nonatomic, assign) CallDirection direction;
@property (nonatomic, strong) NSString *callId;

@end

@implementation CallInfo
//MARK: - Class Methods
+ (CallInfo *)callInfoWithCallID:(NSString *)callId
                         members:(NSDictionary<NSNumber *, NSString *>*)members
                       direction:(CallDirection)direction {
    return [[CallInfo alloc] initWithCallID:callId members:members direction:direction];
}

//MARK - Setup
- (NSNumber *)localParticipantId {
    return @(self.profile.ID);
}

- (NSArray<CallParticipant *> *)interlocutors {
    NSMutableArray<CallParticipant *> *interlocutors = [NSMutableArray array];
    for (NSNumber *userID in self.list) {
        if (userID.unsignedIntValue == self.profile.ID) { continue; }
        CallParticipant *participant = [self participantWithId:userID];
        if (participant) {
            [interlocutors addObject:participant];
        }
    }
    return  interlocutors;
}

- (NSArray<CallParticipant *> *)participants {
    NSMutableArray<CallParticipant *> *participants = [NSMutableArray array];
    for (NSNumber *userID in self.list) {
        CallParticipant *participant = [self participantWithId:userID];
        if (participant) {
            [participants addObject:participant];
        }
    }
    return  participants;
}

//MARK: - Life Cycle
- (void)clear {
    self.onChangedState = nil;
    self.onChangedBitrate = nil;
    self.onUpdatedParticipant = nil;
    [QBRTCClient.instance removeDelegate:self];
}

- (instancetype)initWithCallID:(NSString *)callId
                        members:(NSDictionary<NSNumber *, NSString *>*)members
                      direction:(CallDirection)direction {
    self = [super init];
    if (self) {
        
        [QBRTCClient.instance addDelegate:self];
        _callId = callId;
        _direction = direction;
        NSMutableArray<NSNumber *>*participantsList = @[].mutableCopy;
        NSMutableDictionary<NSString *, CallParticipant*>*participantsDictionary = @{}.mutableCopy;
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterNoStyle;
        
        for (NSNumber *memberId in members.allKeys) {
            NSString *name = members[memberId];
            CallParticipant *participant = [[CallParticipant alloc] initWithParticipantId:memberId fullName:name];
            participantsDictionary[memberId] = participant;
            [participantsList addObject:memberId];
        }
        Profile *profile = [[Profile alloc] init];
        NSNumber *localId = @(profile.ID);
        CallParticipant *local =
        [[CallParticipant alloc] initWithParticipantId:localId fullName:profile.fullName];
        participantsDictionary[localId] = local;
        [participantsList addObject:localId];
        
        _cache = participantsDictionary.copy;
        _list = participantsList.copy;
        _profile = profile;
    }
    return self;
}

// MARK: - Public Methods
- (CallParticipant *)participantWithId:(NSNumber *)userId {
    return self.cache[userId];
}

- (void)updateWithMembers:(NSDictionary<NSNumber *,NSString *> *)members {
    for (NSNumber *userId in members.allKeys) {
        CallParticipant *participant = self.cache[userId];
        if (![participant.fullName isEqualToString:members[userId]] && self.onUpdatedParticipant) {
            self.onUpdatedParticipant(userId, members[userId]);
        }
        participant.fullName = members[userId];
    }
}

// MARK: - QBRTCClientDelegate
- (void)session:(__kindof QBRTCBaseSession *)session
didChangeConnectionState:(QBRTCConnectionState)state
        forUser:(NSNumber *)userID {
    if (![self isCurrentSession:session] || !self.cache[userID]) {
        return;
    }
    CallParticipant *participant = self.cache[userID];
    participant.connectionState = state;
    if (self.onChangedState) {
        self.onChangedState(participant);
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session
updatedStatsReport:(QBRTCStatsReport *)report
      forUserID:(NSNumber *)userID {
    if (![self isCurrentSession:session] || !self.cache[userID]) {
        return;
    }
    if (self.onChangedBitrate) {
        self.onChangedBitrate(userID, report.statsString);
    }
}

//MARK: - Helpers
- (BOOL)isCurrentSession:(__kindof QBRTCBaseSession *)session {
    QBRTCSession *fullSession = (QBRTCSession *)session;
    return [self.callId isEqualToString:fullSession.ID];
}

@end
