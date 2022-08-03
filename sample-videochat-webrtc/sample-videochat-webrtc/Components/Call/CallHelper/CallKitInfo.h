//
//  CallKitInfo.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 11.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallKitInfo : NSObject

@property (nonatomic, strong, readonly) NSString *sessionId;
@property (nonatomic, strong, readonly) NSUUID *uuid;
@property (nonatomic, assign, readonly) BOOL hasVideo;

- (id)initWithSessionId:(NSString *)sessionId hasVideo:(BOOL)hasVideo;

@end

NS_ASSUME_NONNULL_END
