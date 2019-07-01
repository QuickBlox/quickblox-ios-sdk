//
//  ConferenceUser.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/14/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject
@property (strong, nonatomic, readonly) QBUUser *user;
@property (assign, nonatomic, readonly) NSNumber *ID;
@property (strong, nonatomic, readonly) NSString *fullName;
@property (assign, nonatomic) double bitrate;
@property (assign, nonatomic) QBRTCConnectionState connectionState;

- (instancetype)initWithID:(NSUInteger)ID fullName:(NSString *)fullName;
- (instancetype)initWithUser:(QBUUser *)user;

@end

NS_ASSUME_NONNULL_END
