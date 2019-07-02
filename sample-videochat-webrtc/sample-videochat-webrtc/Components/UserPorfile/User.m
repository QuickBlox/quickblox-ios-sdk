//
//  ConferenceUser.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/14/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "User.h"

@implementation User

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

- (instancetype)initWithUser:(QBUUser *)user {
    self = [super init];
    if (self) {
        _user = user;
        _fullName = user.fullName;
        _ID = @(user.ID);
        _connectionState = QBRTCConnectionStateConnected;
    }
    return self;
}

@end
