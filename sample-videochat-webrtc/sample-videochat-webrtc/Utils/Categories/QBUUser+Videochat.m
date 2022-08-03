//
//  QBUUser+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "QBUUser+Videochat.h"

@implementation QBUUser (Videochat)

- (NSString *)name {
    if (self.fullName.length) {
        return self.fullName;
    } else if (self.login.length) {
        return self.login;
    } else {
        return [NSString stringWithFormat:@"%@", @(self.ID)];
    }
}

@end
