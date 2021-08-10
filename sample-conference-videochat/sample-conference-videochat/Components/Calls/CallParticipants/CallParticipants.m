//
//  Participants.m
//  sample-conference-videochat
//
//  Created by Injoit on 21.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallParticipants.h"
#import "Profile.h"

@interface CallParticipants ()
//MARK: - Properties
/// Sorted participants ids.
@property (nonatomic, strong) NSMutableArray<NSNumber *>*list;
/// The call participants details where the key is a user id.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, CallParticipant *>*cache;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIView *>*viewCache;

@property (nonatomic, strong) Profile *profile;

@end

@implementation CallParticipants

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = @{}.mutableCopy;
        _list = @[].mutableCopy;
        _participants = @[].mutableCopy;
        _viewCache = @{}.mutableCopy;
        _profile = [[Profile alloc] init];
    }
    return self;
}

//MARK: - Public Methods
- (NSNumber *)localId {
    return @(self.profile.ID);
}

- (NSUInteger)count {
    return self.list.count;
}

- (void)addParticipantWithId:(NSNumber *)userId fullName:(NSString *)fullName {
    CallParticipant *participant = [[CallParticipant alloc] initWithID:userId fullName:fullName];
    if (self.cache[userId] != nil) {
        self.cache[userId] = participant;
        return;
    }
    self.cache[userId] = participant;
    [self.list insertObject:userId atIndex:0];
    [self.participants insertObject:participant atIndex:0];
}

- (NSUInteger)participantIndexWithId:(NSNumber *)userId {
    return [self.list indexOfObject:userId];
}

- (NSNumber *)participantIdWithIndex:(NSUInteger)index {
    return self.list[index];
}

- (CallParticipant *)participantWithId:(NSNumber *)userId {
    return self.cache[userId];
}

- (CallParticipant *)participantWithIndex:(NSUInteger)index {
    NSNumber *userId = self.list[index];
    return [self participantWithId:userId];
}

- (UIView *)videoViewWithIndex:(NSUInteger)index {
    NSNumber *userId = self.list[index];
    return self.viewCache[userId];
}

- (UIView *)videoViewWithId:(NSNumber *)userId {
    return self.viewCache[userId];
}

- (void)addVideView:(UIView *)view withId:(NSNumber *)userId {
    self.viewCache[userId] = view;
}

- (void)removeParticipantWithId:(NSNumber *)userId {
    NSUInteger index = [self participantIndexWithId:userId];
    [self.participants removeObjectAtIndex:index];
    [self.list removeObject:userId];
    [self.cache removeObjectForKey:userId];
    [self removeVideViewWithId:userId];
}

//MARK: - Private Methods
- (void)removeVideViewWithId:(NSNumber *)userId {
    [self.viewCache removeObjectForKey:userId];
}

@end
