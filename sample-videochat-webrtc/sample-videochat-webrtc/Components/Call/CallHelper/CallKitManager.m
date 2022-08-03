//
//  CallKit.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 26.05.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "CallKitManager.h"
#import "Log.h"
#import "CallKitInfo.h"

static const NSInteger DefaultMaximumCallsPerCallGroup = 1;
static const NSInteger DefaultMaximumCallGroups = 1;

@interface CallKitManager ()

@property (strong, nonatomic) CXProvider *provider;
@property (strong, nonatomic) CXCallController *callController;
@property (strong, nonatomic) CallKitInfo *call;
@property (strong, nonatomic) QBRTCAudioSession  *qbAudioSession;
@property (assign, nonatomic) BOOL reportEndCall;

@end

@interface CallKitManager (Provider) <CXProviderDelegate>
@end

@implementation CallKitManager

+ (CXProviderConfiguration *)configuration {
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] init];
    config.supportsVideo = YES;
    config.maximumCallsPerCallGroup = DefaultMaximumCallsPerCallGroup;
    config.maximumCallGroups = DefaultMaximumCallGroups;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"qb-logo"]);
    config.ringtoneSound = @"ringtone.wav";
    return config;
}

- (NSUUID *)callUUID {
    return self.call.uuid;
}

// MARK: - Initialization
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        CXProviderConfiguration *configuration = [CallKitManager configuration];
        self.provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [self.provider setDelegate:self queue:nil];
        self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
        self.qbAudioSession = [QBRTCAudioSession instance];
        self.reportEndCall = NO;
    }
    return self;
}

// MARK: - Actions

- (void)reportIncomingCall:(NSString *)sessionId
                     title:(NSString *)title
                  hasVideo:(BOOL)hasVideo
                     state:(IncommingCallState)state
                completion:(void (^)(void))completion {
    CXCallUpdate *update = [self callUpdateWithTitle:title
                                            hasVideo:hasVideo];
    CallKitInfo *call = [[CallKitInfo alloc] initWithSessionId:sessionId hasVideo:hasVideo];
    self.call = call;
    [self.provider reportNewIncomingCallWithUUID:call.uuid
                                          update:update
                                      completion:^(NSError * _Nullable error) {
        if (completion != nil) {
            completion();
        }
        if (error) {
            Log(@"[%@] Error: %@",  NSStringFromClass(CallKitManager.class), error);
            return;
        }
        CXCallEndedReason reason;
        switch (state) {
            case IncommingCallStateValid:
                self.qbAudioSession.useManualAudio = YES;
                return;
            case IncommingCallStateMissed: reason = CXCallEndedReasonRemoteEnded;
                break;
            case IncommingCallStateInvalid: reason = CXCallEndedReasonUnanswered;
                break;
        }
        self.call = nil;
        [self.provider reportCallWithUUID:call.uuid
                              endedAtDate:NSDate.date
                                   reason:reason];
    }];
}

- (void)reportOutgoingCall:(NSString *)sessionId
                     title:(NSString *)title
                  hasVideo:(BOOL)hasVideo
                completion:(void (^)(void))completion {
    CallKitInfo *call = [[CallKitInfo alloc] initWithSessionId:sessionId hasVideo:hasVideo];
    self.call = call;
    CXHandle *handle = [self handleWithText:title];
    
    CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:call.uuid
                                                                     handle:handle];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    
    [self.callController requestTransaction:transaction completion:^(NSError *error) {
        if (error != nil) {
            Log(@"[%@] Error: %@",  NSStringFromClass(CallKitManager.class), error);
        }
        if (completion) { completion(); }
    }];
}

- (void)reportEndCall:(NSString *)sessionId {
    if (![sessionId isEqualToString:self.call.sessionId]) {
        return;
    }
    
    self.reportEndCall = YES;
    
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:self.call.uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    
    [self.callController requestTransaction:transaction completion:^(NSError *error) {
        if (error == nil) {
            return;
        }
        Log(@"[%@] Error: %@",  NSStringFromClass(CallKitManager.class), error);
    }];
}

- (void)reportEndCall:(NSString *)sessionId reason:(CXCallEndedReason)reason {
    if (![sessionId isEqualToString:self.call.sessionId]) {
        return;
    }
    
    [self.provider reportCallWithUUID:self.call.uuid
                          endedAtDate:NSDate.date
                               reason:reason];
    [self closeCallWithSessionID:sessionId];
}

- (void)reportAcceptCall:(NSString *)sessionId {
    NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:sessionId];
    NSArray *actions = [self.provider pendingCallActionsOfClass:CXAnswerCallAction.class
                                                   withCallUUID:callUUID];
    for (CXAction *action in actions) {
        CXAnswerCallAction *answer = (CXAnswerCallAction *)action;
        [answer fulfillWithDateConnected:NSDate.date];
    }
}

- (void)reportUpdateCall:(NSString *)sessionId
                   title:(NSString *)title {
    if (!title.length) {
        return;
    }
    NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:sessionId];
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [self handleWithText:title];
    update.localizedCallerName = title;
    
    [self.provider reportCallWithUUID:callUUID updated:update];
}

- (void)muteAudio:(BOOL)mute call:(NSString *)sessionId {
    if (![sessionId isEqualToString:self.call.sessionId]) {
        return;
    }
    
    CXSetMutedCallAction *action = [[CXSetMutedCallAction alloc] initWithCallUUID:self.call.uuid muted:mute];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    [self.callController requestTransaction:transaction completion:^(NSError *error) {
        if (error != nil) {
            Log(@"[%@] Error: %@",  NSStringFromClass(CallKitManager.class), error);
        }
    }];
}

- (void)closeCallWithSessionID:(NSString *)sessionID {
    self.qbAudioSession.audioEnabled = NO;
    self.qbAudioSession.useManualAudio = NO;
    if (self.reportEndCall) {
        if ([self.delegate respondsToSelector:@selector(callKit:didEndCall:)]) {
            [self.delegate callKit:self didEndCall:self.call.sessionId];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(callKit:didTapRedject:)]) {
            [self.delegate callKit:self didTapRedject:self.call.sessionId];
        }
    }
    
    self.reportEndCall = NO;
    self.call = nil;
}

//MARK: - Internal
- (CXCallUpdate *)callUpdateWithTitle:(NSString *)title
                             hasVideo:(BOOL)hasVideo {
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.localizedCallerName = title;
    update.supportsHolding = NO;
    update.supportsGrouping = NO;
    update.supportsUngrouping = NO;
    update.supportsDTMF = NO;
    update.hasVideo = hasVideo;
    
    return update;
}

- (CXHandle *)handleWithText:(NSString *)text {
    return [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:text];
}

- (void)updateAudioSessionConfiguration:(BOOL)hasVideo {
    
    QBRTCAudioSessionConfiguration *configuration = [[QBRTCAudioSessionConfiguration alloc] init];
    configuration.categoryOptions |= AVAudioSessionCategoryOptionDuckOthers;
    
    // adding blutetooth support
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    
    // adding airplay support
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
    
    if (hasVideo) {
        configuration.mode = AVAudioSessionModeVideoChat;
    }
    [self.qbAudioSession setConfiguration:configuration];
}

@end

@implementation CallKitManager (Provider)

- (void)providerDidReset:(nonnull CXProvider *)provider {
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    if ([action.callUUID isEqual:self.callUUID] == NO) {
        [action fail];
        return;
    }
    
    [self updateAudioSessionConfiguration:self.call.hasVideo];
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    if ([action.callUUID isEqual:self.callUUID] == NO) {
        [action fail];
        return;
    }
    
    [self updateAudioSessionConfiguration:self.call.hasVideo];
    
    if ([self.delegate respondsToSelector:@selector(callKit:didTapAnswer:)]) {
        [self.delegate callKit:self didTapAnswer:self.call.sessionId];
    }
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    if ([action.callUUID isEqual:self.callUUID] == NO && self.call) {
        [action fail];
        return;
    }
    
    [self closeCallWithSessionID:self.call.sessionId];
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    [self.qbAudioSession audioSessionDidActivate:audioSession];
    self.qbAudioSession.audioEnabled = YES;
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    [self.qbAudioSession audioSessionDidDeactivate:audioSession];
}

- (void)provider:(CXProvider *)__unused provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    if ([action.callUUID isEqual:self.callUUID] == NO) {
        [action fail];
        return;
    }
    if ([self.actionDelegate respondsToSelector:@selector(callKit:didTapMute:)]) {
        [self.actionDelegate callKit:self didTapMute:action.isMuted];
    }
    [action fulfill];
}

@end
