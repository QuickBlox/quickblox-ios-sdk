//
//  Session.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 17.06.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Session : NSObject
@property (nonatomic, strong, readonly) NSString *id;
@property (nonatomic, assign) BOOL videoEnabled;
@property (nonatomic, assign) BOOL audioEnabled;
@property (nonatomic, weak) QBRTCVideoCapture *videoCapture;
@property (assign, nonatomic, readonly) BOOL established;
@property (assign, nonatomic, readonly) NSTimeInterval waitTimeInterval;

+ (Session *)sessionWithId:(NSString *)id startTime:(NSTimeInterval)startTime;
+ (Session *)sessionWithQBSession:(QBRTCSession *)qbSession startTime:(NSTimeInterval)startTime;

- (void)setupWithQBSession:(QBRTCSession *)qbSession;
- (void)startWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo;
- (void)acceptWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo;
- (void)rejectWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo;
- (void)hangUpWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo;
- (QBRTCVideoTrack *)remoteVideoTrackWithUserID:(NSNumber *)userID;

@end

NS_ASSUME_NONNULL_END
