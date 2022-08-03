//
//  SessionsController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 26.05.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "SessionsController.h"
#import "SessionTimer.h"
#import "Profile.h"
#import <AVFoundation/AVFoundation.h>
#import "Session.h"
#import "NSDate+Videochat.h"

@interface SessionsController()

@property (nonatomic, strong) Session *activeSession;
@property (nonatomic, strong) NSString *activeSessionId;
@property (nonatomic, strong) NSMutableDictionary<NSString *, SessionTimer *>*waitSessions;
@property (nonatomic, strong) NSMutableArray<NSString *> *receivedSessions;
@property (nonatomic, strong) NSMutableArray<NSString *> *approvedSessions;
@property (nonatomic, strong) NSMutableSet<NSString *> *rejectedSessions;
@property (nonatomic, strong) NSTimer *soundTimer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *stopIntervals;

- (void)removeSessionWithId:(NSString *)sessionId;

@end

@interface SessionsController (Timer) <SessionTimerDelegate>
@end

@interface SessionsController (Client) <QBRTCClientDelegate>
@end



@implementation SessionsController

- (instancetype)init {
    self = [super init];
    if (self) {
        _receivedSessions = @[].mutableCopy;
        _activeSessionId = @"";
        _waitSessions = @{}.mutableCopy;
        _approvedSessions = @[].mutableCopy;
        _rejectedSessions = [NSMutableSet set];
        _stopIntervals = @{}.mutableCopy;
        [QBRTCClient.instance addDelegate:self];
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"calling" ofType:@"wav"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundPath] error: nil];
        self.audioPlayer.volume = 1.0;
    }
    return self;
}

- (NSString *)activeSessionId {
    return self.activeSession.id;
}

//MARK: Actions
- (NSDictionary *)activateWithMembers:(NSDictionary<NSNumber *, NSString *>*)members
                             hasVideo:(BOOL)hasVideo {
    QBRTCConferenceType type = hasVideo ? QBRTCConferenceTypeVideo : QBRTCConferenceTypeAudio;
    QBRTCSession *session =
    [QBRTCClient.instance createNewSessionWithOpponents:members.allKeys
                                     withConferenceType:type];
    if (!session) {
        return @{};
    }
    [self.receivedSessions addObject:session.ID];
    
    NSTimeInterval timeNow = [[NSDate date] currentTimestamp];
    self.activeSession = [Session sessionWithQBSession:session startTime:timeNow];
    NSString *timeStamp = [NSString stringWithFormat:@"%f", timeNow];
    
    
    [self activate:session.ID  timestamp:nil];
    
    Profile *profile = [[Profile alloc] init];
    NSString *initiatorName = profile.fullName;
    NSString *membersNames = [members.allValues componentsJoinedByString:@","];
    NSString *participantsNames =
    [NSString stringWithFormat:@"%@,%@", initiatorName, membersNames];
    NSString *membersIds = [members.allKeys componentsJoinedByString:@","];
    NSString *participantsIds = [NSString stringWithFormat:@"%@,%@", @(profile.ID), membersIds];
    
    
    NSDictionary *payload = @{
        @"message"  : [NSString stringWithFormat:@"%@ is calling you.", initiatorName],
        @"ios_voip" : @"1",
        @"VOIPCall"  : @"1",
        @"sessionID" : session.ID,
        @"opponentsIDs" : participantsIds,
        @"contactIdentifier" : participantsNames,
        @"conferenceType" : @(type).stringValue,
        @"timestamp" : timeStamp
    };
    
    return payload;
}

- (void)activate:(NSString *)sessionId timestamp:(NSString * _Nullable)timestamp {
    if (!sessionId.length) {
        return;
    }
    if (self.activeSessionId.length) {
        return;
    }
    
    NSTimeInterval timeNow = [[NSDate date] currentTimestamp];
    NSTimeInterval startCallTime = timestamp ? timestamp.longLongValue : timeNow;
    
    if (self.activeSession.established == true) {
        [self addTimer:SessionTimerTypeActions
                  wait: self.activeSession.waitTimeInterval
             sessionId:sessionId
              userInfo:nil];
        return;
    }
    self.activeSession = [Session sessionWithId:sessionId startTime:startCallTime];
    [self addTimer:SessionTimerTypeActive
              wait:self.activeSession.waitTimeInterval
         sessionId:sessionId
          userInfo:nil];
}

- (void)deactivate:(NSString *)sessionId {
    if (!sessionId.length) {
        return;
    }
    if (![self.activeSessionId isEqualToString:sessionId]) {
        return;
    }
    [self.rejectedSessions addObject:sessionId];
    [self stopPlayCallingSound];
    self.activeSession = nil;
}

- (void)start:(NSString *)sessionId userInfo:(NSDictionary<NSString *,NSString *> *)info {
    if (!sessionId.length) {
        return;
    }
    
    if (![self.activeSessionId isEqualToString:sessionId]) {
        return;
    }
    
    [self.activeSession startWithUserInfo:info];
    [self.approvedSessions addObject:sessionId];
    [self removeTimerWithId:sessionId];
    [self playCallingSound];
}

- (void)accept:(NSString *)sessionId userInfo:(NSDictionary<NSString *, NSString *> *)info {
    if (!sessionId.length) {
        return;
    }
    if (self.activeSession.established) {
        [self.activeSession acceptWithUserInfo:info];
        [self.approvedSessions addObject:sessionId];
        if ([self.delegate respondsToSelector:@selector(controller:didAcceptSession:)]) {
            [self.delegate controller:self didAcceptSession:sessionId];
        }
        [self addTimer:SessionTimerTypeConnected
                  wait:7.0f
             sessionId:sessionId
              userInfo:info];
    } else {
        [self addTimer:SessionTimerTypeAccept
                  wait:self.activeSession.waitTimeInterval
             sessionId:sessionId
              userInfo:info];
    }
}

- (void)reject:(NSString *)sessionId userInfo:(NSDictionary<NSString *, NSString *> *)info {
    if (!sessionId.length) {
        return;
    }
    [self.rejectedSessions addObject:sessionId];
    if (self.activeSession.established) {
        [self.approvedSessions containsObject:sessionId] ?
        [self.activeSession hangUpWithUserInfo:info] : [self.activeSession rejectWithUserInfo:info];
    } else {
        [self removeSessionWithId:sessionId];
    }
}

- (BOOL)session:(NSString *)sessionId confirmToState:(SessionState)state {
    switch (state) {
        case SessionStateReceived:
            return [self.receivedSessions containsObject:sessionId];
            break;
        case SessionStateWait:
            return self.waitSessions[sessionId] != nil;
            break;
        case SessionStateApproved:
            return [self.approvedSessions containsObject:sessionId];
            break;
        case SessionStateRejected:
            return [self.rejectedSessions containsObject:sessionId];
            break;
        case SessionStateNew:
            if (self.waitSessions[sessionId] == nil
                && [self.receivedSessions containsObject:sessionId] == false
                && [self.approvedSessions containsObject:sessionId] == false
                && [self.rejectedSessions containsObject:sessionId] == false ) {
                return YES;
            }
            return NO;
            break;
            
        default:
            break;
    }
}

//MARK: Internal
- (void)removeSessionWithId:(NSString *)sessionId {
    if ([self.receivedSessions containsObject:sessionId]) {
        [self.receivedSessions removeObject:sessionId];
    }
    [self removeTimerWithId:sessionId];
    [self.approvedSessions removeObject:sessionId];
    if ([sessionId isEqualToString:self.activeSessionId]) {
        if ([self.delegate respondsToSelector:@selector(controller:didCloseSession:)]) {
            [self.delegate controller:self didCloseSession:sessionId];
        }
        [self deactivate:sessionId];
    }
}

- (void)removeTimerWithId:(NSString *)sessionId {
    SessionTimer *timer = self.waitSessions[sessionId];
    if (timer) {
        [timer invalidate];
        [self.waitSessions removeObjectForKey:sessionId];
    }
}

- (void)addTimer:(SessionTimerType)type
            wait:(NSTimeInterval)time
       sessionId:(NSString *)sessionId
        userInfo:(NSDictionary<NSString *, NSString *> *)info {
    [self removeTimerWithId:sessionId];
    SessionTimer *timer = [SessionTimer waitSession:sessionId
                                               type:type
                                        waitingTime:time];
    timer.delegate = self;
    timer.userInfo = info;
    self.waitSessions[sessionId] = timer;
}

- (void)playCallingSound {
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                       target:self
                                                     selector:@selector(playSound)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)playSound {
    [self.audioPlayer stop];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)stopPlayCallingSound {
    if (self.soundTimer == nil) {
        return;
    }
    [self.soundTimer invalidate];
    self.soundTimer = nil;
    [self.audioPlayer stop];
}

@end

@implementation SessionsController (Timer)

- (void)timerDidEndWaiting:(nonnull SessionTimer *)timer {
    if ([self.activeSessionId isEqualToString:timer.sessionId] &&
        [self.delegate respondsToSelector:@selector(controller:didEndWaitSession:)]) {
        [self reject:timer.sessionId userInfo:timer.userInfo];
        [self.delegate controller:self didEndWaitSession:timer.sessionId];
        return;
    }
    [self removeTimerWithId:timer.sessionId];
}

@end

@implementation SessionsController (Client)

- (void)didReceiveNewSession:(QBRTCSession *)session
                    userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (self.activeSession.id &&
        [self.activeSession.id isEqualToString:session.ID] == NO) {
        [session rejectCall:@{@"reject": @"busy"}];
        [self.rejectedSessions addObject:session.ID];
        return;
    }
    if ([self.rejectedSessions containsObject:session.ID]) {
        [session rejectCall:@{@"reject": @"busy"}];
        return;
    }
    
    [self.receivedSessions addObject: session.ID];
    
    SessionTimer *timer = self.waitSessions[session.ID];
    if (timer) {
        switch (timer.type) {
            case SessionTimerTypeActive: {
                [self.activeSession setupWithQBSession:session];
                break;
            }
            case SessionTimerTypeAccept: {
                [self.activeSession setupWithQBSession:session];
                [self accept:session.ID userInfo:timer.userInfo];
                break;
            }
            case SessionTimerTypeConnected:
            case SessionTimerTypeActions: {
                break;
            }
        }
        return;
    }
    
    
    //did Receive New Session without Push
    NSTimeInterval timeNow = [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue];
    NSString *timestamp = userInfo[@"timestamp"] ?: [NSString stringWithFormat:@"%f", timeNow];
    
    self.activeSession = [Session sessionWithQBSession:session startTime:timestamp.longLongValue];
    
    NSArray *membersIDs = [@[session.initiatorID] arrayByAddingObjectsFromArray:session.opponentsIDs];
    NSString *participantsIds = [membersIDs componentsJoinedByString:@","];
    NSDictionary *payload = @{
        @"sessionID" : session.ID,
        @"opponentsIDs" : participantsIds,
        @"conferenceType" : @(session.conferenceType).stringValue,
        @"timestamp" : timestamp
    };
    if ([self.delegate respondsToSelector:@selector(controller:didReceiveIncomingSession:)]) {
        [self.delegate controller:self didReceiveIncomingSession:payload];
    }
}

- (void)session:(QBRTCSession *)session
 acceptedByUser:(NSNumber *)userID
       userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    [self stopPlayCallingSound];
}

- (void)session:(QBRTCSession *)session
   hungUpByUser:(NSNumber *)userID
       userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (userID == session.initiatorID &&
        ![self.approvedSessions containsObject:session.ID]) {
        [self removeSessionWithId:session.ID];
        return;
    }
    if (session.opponentsIDs.count < 2) {
        [self removeSessionWithId:session.ID];
    }
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if (session.opponentsIDs.count == 1) {
        [self removeSessionWithId:session.ID];
    }
}

- (void)sessionDidClose:(QBRTCSession *)session {
    [self removeSessionWithId:session.ID];
}

- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(nonnull QBRTCVideoTrack *)videoTrack fromUser:(nonnull NSNumber *)userID {
    QBRTCSession *fullSession = (QBRTCSession *)session;
    if (![fullSession.ID isEqualToString:self.activeSession.id]) {
        return;
    }
    if ([self.mediaListenerDelegate respondsToSelector:@selector(controller:didReceivedRemoteVideoTrack:fromUser:)]) {
        [self.mediaListenerDelegate controller:self didReceivedRemoteVideoTrack:videoTrack fromUser:userID];
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session connectedToUser:(NSNumber *)userID {
    QBRTCSession *fullSession = (QBRTCSession *)session;
    if (![fullSession.ID isEqualToString:self.activeSession.id]) {
        return;
    }
    if (!self.waitSessions[fullSession.ID]) {
        return;
    }
    [self removeTimerWithId:fullSession.ID];
}

@end

//MARK - MediaControllerDelegate
@implementation SessionsController (MediaControllerDelegate)
- (void)mediaController:(nonnull MediaController *)mediaController videoBroadcastEnable:(BOOL)enabled capture:(QBRTCVideoCapture * _Nullable)capture {
    if (capture) {
        self.activeSession.videoCapture = capture;
    }
    self.activeSession.videoEnabled = enabled;
    if ([self.mediaListenerDelegate respondsToSelector:@selector(controller:didBroadcastMediaType:enabled:)]) {
        [self.mediaListenerDelegate controller:self didBroadcastMediaType:MediaTypeVideo enabled:enabled];
    }
}

- (void)mediaController:(nonnull MediaController *)mediaController audioBroadcastEnable:(BOOL)enabled reason:(ChangeAudioStateReason)reason {
    if (self.activeSession.audioEnabled == enabled) {
        return;
    }
    self.activeSession.audioEnabled = enabled;
    if ([self.mediaListenerDelegate respondsToSelector:@selector(controller:didBroadcastMediaType:enabled:)]) {
        [self.mediaListenerDelegate controller:self didBroadcastMediaType:MediaTypeAudio enabled:enabled];
    }
    //Change audio state on CallKit Native Screen
    if (reason == ChangeAudioStateReasonActionCallKit) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(controller:didChangeAudioState:session:)]) {
        [self.delegate controller:self didChangeAudioState:enabled session:self.activeSessionId];
    }
}

- (QBRTCVideoTrack * _Nullable)mediaController:(MediaController *)mediaController videoTrackForUserID:(NSNumber *)userID {
    if (!self.activeSession.established) { return nil; }
    return [self.activeSession remoteVideoTrackWithUserID:userID];
}

@end
