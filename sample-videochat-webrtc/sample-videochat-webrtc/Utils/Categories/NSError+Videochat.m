//
//  NSError+Videochat.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 07.10.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import "NSError+Videochat.h"

@implementation NSError (Videochat)
- (BOOL)isNetworkError {
    NSArray *errors = @[@(NSURLErrorNetworkConnectionLost),
                        @(NSURLErrorNotConnectedToInternet),
                        @(NSURLErrorDataNotAllowed),
                        @(NSURLErrorTimedOut),
                        @(ErrorCodeNodenameNorServnameProvided),
                        @(ErrorCodeSocketIsNotConnected)
    ];
    return [errors containsObject:@(self.code)];
}

@end
