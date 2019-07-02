//
//  ConferenceUser.m
//  sample-videochat-webrtc
//
//  Created by Vladimir Nybozhinsky on 3/14/19.
//  Copyright © 2019 QuickBlox Team. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithID:(NSUInteger)ID fullName:(NSString *)fullName
{
    self = [super init];
    if (self) {
        _ID = ID;
        _fullName = fullName;
    }
    return self;
}

@end
