//
//  ConferenceUser.m
//  sample-conference-videochat
//
//  Created by Injoit on 6/1/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ConferenceUser.h"

@implementation ConferenceUser

- (instancetype)initWithID:(NSUInteger)ID fullName:(NSString *)fullName
{
    self = [super init];
    if (self) {
        _ID = @(ID);
        _fullName = fullName;
        _connectionState = QBRTCConnectionStateConnected;
    }
    return self;
}

@end
