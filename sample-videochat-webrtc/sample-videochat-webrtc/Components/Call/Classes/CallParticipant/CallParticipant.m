//
//  CallParticipant.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallParticipant.h"

@implementation CallParticipant

- (instancetype)initWithParticipantId:(NSNumber *)participantId fullName:(NSString *)fullName {
    //MARK: - Life Cycle
    self = [super init];
    if (self) {
        _id = participantId;
        _fullName = fullName;
        _connectionState = QBRTCConnectionStateNew;
        _isSelected = NO;
        _isEnabledSound = YES;
    }
    return self;
}

@end
