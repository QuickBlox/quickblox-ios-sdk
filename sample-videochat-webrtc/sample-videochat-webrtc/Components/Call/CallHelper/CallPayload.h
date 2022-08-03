//
//  CallPayload.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 11.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallPayload : NSObject

/// Some call data wrong or absent
@property (nonatomic, assign, readonly) BOOL valid;
@property (nonatomic, assign, readonly) BOOL missed;
@property (nonatomic, assign, readonly) BOOL hasVideo;
@property (nonatomic, strong, readonly) NSString *timestamp;
@property (nonatomic, strong, readonly) NSString *sessionID;
/// The call participants without a current user. The key is a user id and the value is a user name.
@property (nonatomic, strong, readonly) NSDictionary<NSNumber *, NSString *>*members;
@property (nonatomic, strong, readonly) NSString *title;

- (instancetype)initWithPayload:(NSDictionary *)payload;

@end

NS_ASSUME_NONNULL_END
