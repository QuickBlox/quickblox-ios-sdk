//
//  NSDate+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 22.06.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import "NSDate+Videochat.h"

@implementation NSDate (Videochat)

- (NSTimeInterval)currentTimestamp {
    return [@(floor([self timeIntervalSince1970] * 1000)) longLongValue];
}

@end
