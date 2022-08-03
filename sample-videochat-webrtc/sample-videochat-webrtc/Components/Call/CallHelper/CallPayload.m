//
//  CallPayload.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 11.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallPayload.h"
#import "Profile.h"
#import "NSDate+Videochat.h"

#define callInfoKey( prop ) NSStringFromSelector(@selector(prop))

@interface CallPayload ()

@property (nonatomic, strong) NSString *opponentsIDs;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) NSString *contactIdentifier;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *conferenceType;

@property (nonatomic, strong) Profile *currentUser;

@end

@implementation CallPayload

- (NSString *)title {
    if (self.members.allValues.count) {
        return [self.members.allValues componentsJoinedByString: @", "];
    }
    return self.contactIdentifier;
}

- (BOOL)valid {
    return self.sessionID.length;
}

- (BOOL)missed {
    if (self.members.count < 1) {
        return YES;
    }
    
    if (!self.timestamp.length) {
        return YES;
    }

    NSTimeInterval startCallTimeInterval = self.timestamp.longLongValue;
    if (startCallTimeInterval) {
        NSTimeInterval timeNow = [[NSDate date] currentTimestamp];
        return (timeNow - startCallTimeInterval) / 1000 > QBRTCConfig.answerTimeInterval;
    }
    
    return NO;
}

- (BOOL)hasVideo {
    return [self.conferenceType isEqualToString:@"1"];
}

- (instancetype)initWithPayload:(NSDictionary *)payload {
    self = [super init];
    if (self) {
        self.opponentsIDs = payload[callInfoKey(opponentsIDs)] ?: @"";
        self.sessionID = payload[callInfoKey(sessionID)] ?: @"";

        NSString *contactIdentifier = payload[callInfoKey(contactIdentifier)];
        NSArray<NSString *>*participantsNames;
        if (contactIdentifier.length) {
            self.contactIdentifier = contactIdentifier;
            participantsNames = [self.contactIdentifier componentsSeparatedByString:@","];
        } else {
            self.contactIdentifier = @"Incoming call. Connecting...";
            participantsNames = [self.opponentsIDs componentsSeparatedByString:@","];
        }
        
        self.timestamp = payload[callInfoKey(timestamp)] ?: @"";
        self.conferenceType = payload[callInfoKey(conferenceType)] ?: @"1";
        
        self.currentUser = [[Profile alloc] init];
        
        _members = @{};
        NSArray<NSString *>*participantsIDs = [self.opponentsIDs componentsSeparatedByString:@","];
        
        if (participantsIDs.count == participantsNames.count) {
            NSMutableArray *ids = @[].mutableCopy;
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            formatter.numberStyle = NSNumberFormatterNoStyle;
            for (NSString *stringId in participantsIDs) {
                [ids addObject:[formatter numberFromString:stringId]];
            }
            NSMutableDictionary *participants =
            [NSMutableDictionary dictionaryWithObjects:participantsNames
                                               forKeys:ids.copy];
            [participants removeObjectForKey:@(self.currentUser.ID)];
            if (participants.count) { _members = participants; }
        }
    }
    return self;
}

@end
