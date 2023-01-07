//
//  Session.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 17.06.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import "Session.h"

@interface Session()
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) QBRTCSession *qbSession;
@property (assign, nonatomic) BOOL established;
@property (assign, nonatomic) NSTimeInterval stopWaitTime;
@end

@implementation Session
//MARK - Properties

+ (Session *)sessionWithId:(NSString *)id startTime:(NSTimeInterval)startTime {
    return [[Session alloc] initWithId:id startTime:startTime];
}

+ (Session *)sessionWithQBSession:(QBRTCSession *)qbSession startTime:(NSTimeInterval)startTime {
    return [[Session alloc] initWithQBSession:qbSession startTime:startTime];
}

- (instancetype)initWithId:(NSString *)id startTime:(NSTimeInterval)startTime {
    self = [super init];
    if (self) {
        _id = id;
        self.stopWaitTime = [@(floor(startTime + ((QBRTCConfig.answerTimeInterval - 1.0f) * 1000))) longLongValue];
        _audioEnabled = YES;
        _videoEnabled = NO;
    }
    return self;
}

- (instancetype)initWithQBSession:(QBRTCSession *)qbSession startTime:(NSTimeInterval)startTime {
    self = [super init];
    if (self) {
        _qbSession = qbSession;
        _id = qbSession.ID;
        self.stopWaitTime = [@(floor(startTime + (QBRTCConfig.answerTimeInterval * 1000))) longLongValue];
        _audioEnabled = YES;
        _videoEnabled = NO;
    }
    return self;
}

- (void)setupWithQBSession:(QBRTCSession *)qbSession {
    if (![self.id isEqualToString:qbSession.ID]) {
        return;
    }
    if ([self.id isEqualToString:qbSession.ID] && self.established == YES) {
        return;
    }
    self.qbSession = qbSession;
    self.qbSession.localMediaStream.audioTrack.enabled = _audioEnabled;
    self.qbSession.localMediaStream.videoTrack.videoCapture = _videoCapture;
    self.qbSession.localMediaStream.videoTrack.enabled = _videoEnabled;
}

- (NSTimeInterval)waitTimeInterval {
    NSTimeInterval timeNow = [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue];
    return [@(floor((self.stopWaitTime - timeNow) / 1000))  longLongValue];
}

- (void)setAudioEnabled:(BOOL)audioEnabled {
    if (_audioEnabled == audioEnabled) {
        return;
    }
    _audioEnabled = audioEnabled;
    self.qbSession.localMediaStream.audioTrack.enabled = audioEnabled;
}

- (void)setVideoEnabled:(BOOL)videoEnabled {
    if (_videoEnabled == videoEnabled) {
        return;
    }
    _videoEnabled = videoEnabled;
    self.qbSession.localMediaStream.videoTrack.enabled = self.videoEnabled;
}

- (void)setVideoCapture:(QBRTCVideoCapture *)videoCapture {
    if (_videoCapture == videoCapture) {
        return;
    }
    _videoCapture = videoCapture;
    self.qbSession.localMediaStream.videoTrack.videoCapture = self.videoCapture;
}

- (BOOL)established {
    return self.qbSession != nil;
}

- (void)startWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (!self.qbSession) {
        return;
    }
    [self.qbSession startCall:userInfo];
}

- (void)acceptWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (!self.qbSession) {
        return;
    }
    [self.qbSession acceptCall:userInfo];
}

- (void)rejectWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (!self.qbSession) {
        return;
    }
    [self.qbSession rejectCall:userInfo];
}

- (void)hangUpWithUserInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (!self.qbSession) {
        return;
    }
    [self.qbSession hangUp:userInfo];
}

- (QBRTCVideoTrack *)remoteVideoTrackWithUserID:(NSNumber *)userID {
    if (!self.qbSession) {
        return nil;
    }
    return [self.qbSession remoteVideoTrackWithUserID:userID];
}
@end
