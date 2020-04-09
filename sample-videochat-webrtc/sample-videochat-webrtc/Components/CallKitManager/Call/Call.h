//
//  Call.h
//  sample-videochat-webrtc
//
//  Created by Vladimir Nybozhinsky on 3/25/20.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CallStatus) {
    CallStatusNone,
    CallStatusInvite,
    CallStatusActive,
    CallStatusEnded
};

@interface Call : NSObject
@property (strong, nonatomic) NSUUID *uuid;
@property (strong, nonatomic) NSString *sessionID;
@property (assign, nonatomic) CallStatus status;

- (instancetype)initWithUUID:(NSUUID *)uuid sessionID:(NSString *)sessionID status:(CallStatus)status;

@end

NS_ASSUME_NONNULL_END
