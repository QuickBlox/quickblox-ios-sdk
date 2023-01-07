//
//  NSError+Chat.m
//  sample-chat
//
//  Created by Injoit on 06.10.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "NSError+Chat.h"

typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorCodeNodenameNorServnameProvided = 8,
    ErrorCodeSocketIsNotConnected = 57
};

@implementation NSError (Chat)
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
