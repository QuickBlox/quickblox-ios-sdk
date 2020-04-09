//
//  Call.m
//  sample-videochat-webrtc
//
//  Created by Vladimir Nybozhinsky on 3/25/20.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "Call.h"

@implementation Call

- (instancetype)initWithUUID:(NSUUID *)uuid sessionID:(NSString *)sessionID status:(CallStatus)status
{
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.sessionID = sessionID;
        self.status = status;
    }
    return self;
}

@end
