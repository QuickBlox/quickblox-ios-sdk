//
//  NSError+Videochat.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 07.10.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorCodeNodenameNorServnameProvided = 8,
    ErrorCodeSocketIsNotConnected = 57,
    ErrorCodeSocketClosedRemote = 7,
    ErrorCodeBrokenPipe = 32
};

@interface NSError (Videochat)
@property(assign, nonatomic, readonly) BOOL isNetworkError;
@end

NS_ASSUME_NONNULL_END
