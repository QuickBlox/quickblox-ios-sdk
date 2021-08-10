//
//  CallParticipant.m
//  sample-conference-videochat
//
//  Created by Injoit on 15.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallParticipant.h"

@implementation CallParticipant

- (instancetype)initWithID:(NSNumber *)ID fullName:(NSString *)fullName {
    self = [super init];
    if (self) {
        _ID = ID;
        _fullName = fullName;
        _connectionState = QBRTCConnectionStateConnected;
        _isEnabledSound = YES;
        _isCameraEnabled = NO;
    }
    return self;
}

@end
