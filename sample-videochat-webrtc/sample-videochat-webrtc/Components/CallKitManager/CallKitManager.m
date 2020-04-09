//
//  CallKitManager.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CallKitManager.h"
#import <CallKit/CallKit.h>
#import "UsersDataSource.h"
#import "Log.h"
#import "AppDelegate.h"

static const NSInteger DefaultMaximumCallsPerCallGroup = 1;
static const NSInteger DefaultMaximumCallGroups = 1;

@interface CallKitManager () <CXProviderDelegate>

@property (assign, nonatomic) BOOL isCallStarted;
@property (strong, nonatomic) CXProvider *provider;
@property (strong, nonatomic) CXCallController *callController;
@property (copy, nonatomic) dispatch_block_t actionCompletionBlock;
@property (copy, nonatomic) CompletionActionBlock onAcceptActionBlock;
@property (weak, nonatomic) QBRTCSession *session;
@property (strong, nonatomic) NSArray<Call *> *calls;
@end

@implementation CallKitManager
// MARK: - Static
+ (CallKitManager *)instance {
    static CallKitManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CallKitManager alloc] init];
    });
    return instance;
}

+ (CXProviderConfiguration *)configuration {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    config.supportsVideo = YES;
    config.maximumCallsPerCallGroup = DefaultMaximumCallsPerCallGroup;
    config.maximumCallGroups = DefaultMaximumCallGroups;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);
    config.ringtoneSound = @"ringtone.wav";
    return config;
}

// MARK: - Initialization
- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.calls = @[];
        CXProviderConfiguration *configuration = [CallKitManager configuration];
        self.provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [self.provider setDelegate:self queue:nil];
        self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
        self.isCallStarted = NO;
    }
    return self;
}

- (Boolean)isCallDidStarted {
    return self.isCallStarted == YES;
}

- (Call * _Nullable)currentCall {
    Log(@"currentCall self.calls %@",  @(self.calls.count));
    Call *currentCall = (Call *)self.calls.firstObject;
    if (currentCall) {
        return currentCall;
    }
    return nil;
}

- (Boolean)isHasSession {
    return self.session != nil;
}

- (void)setupSession:(QBRTCSession *)session {
    _session = session;
    if ([self.delegate respondsToSelector:@selector(callKitManager:didUpdateSession:)]) {
        [self.delegate callKitManager:self didUpdateSession:session];
    }
}

- (void)setIsCallStarted:(BOOL)isCallStarted {
    if (_isCallStarted != isCallStarted) {
        _isCallStarted = isCallStarted;
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication.sharedApplication delegate];
        appDelegate.isCalling = _isCallStarted;
    }
}

// MARK: - Call management
- (void)startCallWithUserIDs:(NSArray *)userIDs session:(QBRTCSession *)session uuid:(NSUUID *)uuid {
    _session = session;
    
    self.calls = @[];
    Call *outgoingCall = [[Call alloc] initWithUUID:uuid sessionID:session.ID status:CallStatusActive];
    self.calls = @[outgoingCall];
    
    NSString *contactIdentifier = nil;
    CXHandle *handle = [self handleForUserIDs:userIDs];
    CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
    action.contactIdentifier = contactIdentifier;
    
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    [self requestTransaction:transaction completion:^(__unused BOOL succeed) {
        CXCallUpdate *update = [[CXCallUpdate alloc] init];
        update.remoteHandle = handle;
        update.localizedCallerName = contactIdentifier;
        update.supportsHolding = NO;
        update.supportsGrouping = NO;
        update.supportsUngrouping = NO;
        update.supportsDTMF = NO;
        update.hasVideo = session.conferenceType == QBRTCConferenceTypeVideo;
        
        [self.provider reportCallWithUUID:uuid updated:update];
    }];
}

- (void)endCallWithUUID:(NSUUID *)uuid completion:(dispatch_block_t)completion {
    Call *currentCall = (Call *)self.calls.firstObject;
    if (!currentCall) {
        return;
    }
    
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:currentCall.uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    self.calls = @[];
    
    dispatchOnMainThread(^{
        [self requestTransaction:transaction completion:nil];
    });
    
    if (completion != nil) {
        _actionCompletionBlock = completion;
    }
}

- (void)reportIncomingCallWithUserIDs:(NSArray *)userIDs
                        outCallerName:(NSString *)callerName
                              session:(QBRTCSession * _Nullable)session
                            sessionID:(NSString *)sessionID
                sessionConferenceType:(QBRTCConferenceType)sessionConferenceType
                                 uuid:(NSUUID *)uuid
                       onAcceptAction:(CompletionActionBlock)onAcceptAction
                           completion:(void (^)(BOOL))completion {
    
    _session = session;
    _onAcceptActionBlock = onAcceptAction;
    
    self.calls = @[];
    Call *incomingCall = [[Call alloc] initWithUUID:uuid sessionID:session.ID status:CallStatusInvite];
    self.calls = @[incomingCall];
    
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.localizedCallerName = callerName;
    update.supportsHolding = NO;
    update.supportsGrouping = NO;
    update.supportsUngrouping = NO;
    update.supportsDTMF = NO;
    update.hasVideo = sessionConferenceType == QBRTCConferenceTypeVideo;
    
    if (self.session) {
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        audioSession.useManualAudio = YES;
        // disabling audio unit for local mic recording in recorder to enable it later
        session.recorder.localAudioEnabled = NO;
        if (!audioSession.isInitialized) {
            [audioSession initializeWithConfigurationBlock:^(QBRTCAudioSessionConfiguration *configuration) {
                // adding blutetooth support
                configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
                configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
                
                // adding airplay support
                configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
                if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSessionModeVideoChat;
                } else if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSessionModeVoiceChat;
                }
            }];
        }
    }
    
    [_provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
        BOOL silent = ([error.domain isEqualToString:CXErrorDomainIncomingCall] && error.code == CXErrorCodeIncomingCallErrorFilteredByDoNotDisturb);
        dispatchOnMainThread(^{
            if (completion != nil) {
                completion(silent);
            }
        });
    }];
}

- (void)updateIncomingCallWithUserIDs:(NSArray *)userIDs
                        outCallerName:(NSString *)callerName
                              session:(QBRTCSession *)session {
    Call *incomingCall = (Call *)self.calls.firstObject;
    if (!incomingCall) {
        return;
    }
    
    if (!self.session) {
        _session = session;
    }
    
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.localizedCallerName = callerName;
    update.supportsHolding = NO;
    update.supportsGrouping = NO;
    update.supportsUngrouping = NO;
    update.supportsDTMF = NO;
    update.hasVideo = session.conferenceType == QBRTCConferenceTypeVideo;
    
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    audioSession.useManualAudio = YES;
    // disabling audio unit for local mic recording in recorder to enable it later
    session.recorder.localAudioEnabled = NO;
    if (!audioSession.isInitialized) {
        [audioSession initializeWithConfigurationBlock:^(QBRTCAudioSessionConfiguration *configuration) {
            // adding blutetooth support
            configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
            configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
            
            // adding airplay support
            configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
            if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
                // setting mode to video chat to enable airplay audio and speaker only
                configuration.mode = AVAudioSessionModeVideoChat;
            } else if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
                // setting mode to video chat to enable airplay audio and speaker only
                configuration.mode = AVAudioSessionModeVoiceChat;
            }
        }];
    }
    
    [_provider reportCallWithUUID:incomingCall.uuid updated:update];
}

- (void)updateCallWithUUID:(NSUUID *)uuid connectingAtDate:(NSDate *)date {
    [_provider reportOutgoingCallWithUUID:uuid startedConnectingAtDate:date];
}

- (void)updateCallWithUUID:(NSUUID *)uuid connectedAtDate:(NSDate *)date {
    [_provider reportOutgoingCallWithUUID:uuid connectedAtDate:date];
}

// MARK: - CXProviderDelegate protocol
- (void)providerDidReset:(CXProvider *)__unused provider {
}

- (void)provider:(CXProvider *)__unused provider performStartCallAction:(CXStartCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        [weakSelf.session startCall:nil];
        weakSelf.isCallStarted = YES;
        [action fulfill];
    });
}

- (void)provider:(CXProvider *)__unused provider performAnswerCallAction:(CXAnswerCallAction *)action {
    Call *incomingCall = (Call *)self.calls.firstObject;
    if (![incomingCall.uuid isEqual:action.callUUID] || incomingCall.status != CallStatusInvite) {
        Log(@"performAnswerCallAction self.calls %@",  @(self.calls.count));
        [action fail];
        return;
    }
    incomingCall.status = CallStatusActive;
    if (self.session) {
        if ([UIDevice currentDevice].systemVersion.integerValue == 10) {
            // Workaround for webrtc on ios 10, because first incoming call does not have audio
            // due to incorrect category: AVAudioSessionCategorySoloAmbient
            // webrtc need AVAudioSessionCategoryPlayAndRecord
            NSError *err = nil;
            if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&err]) {
                Log(@"[%@] Error setting category for webrtc workaround on ios 10.",  NSStringFromClass([CallKitManager class]));
            }
        }
        [self.session acceptCall:nil];
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        
        weakSelf.isCallStarted = YES;
        [action fulfill];
        
        if (weakSelf.onAcceptActionBlock != nil) {
            weakSelf.onAcceptActionBlock(YES);
            weakSelf.onAcceptActionBlock = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performEndCallAction:(CXEndCallAction *)action {
    
    if (self.calls.count > 0) {
        Call *call = (Call *)self.calls.firstObject;
        call.status = CallStatusEnded;
        if (![call.uuid isEqual:action.callUUID]) {
            self.calls = @[];
            [action fail];
            return;
        }
    }
    
    if (self.session) {
        QBRTCSession *session = self.session;
        _session = nil;
        
        if (self.isCallStarted == YES) {
            [session hangUp:nil];
            self.isCallStarted = NO;
        } else {
            [session rejectCall:nil];
        }
        self.calls = @[];
        
        [action fulfillWithDateEnded:[NSDate date]];
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        audioSession.audioEnabled = NO;
        audioSession.useManualAudio = NO;
        [audioSession deinitialize];
        self.isCallStarted = NO;
        [action fulfillWithDateEnded:[NSDate date]];
        
        if (weakSelf.onAcceptActionBlock != nil) {
            weakSelf.onAcceptActionBlock(NO);
            weakSelf.onAcceptActionBlock = nil;
        }
        
        if (weakSelf.actionCompletionBlock != nil) {
            weakSelf.actionCompletionBlock();
            weakSelf.actionCompletionBlock = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        if (weakSelf.session) {
            weakSelf.session.localMediaStream.audioTrack.enabled = !action.isMuted;
        }
        [action fulfill];
        
        if (weakSelf.onMicrophoneMuteAction != nil) {
            weakSelf.onMicrophoneMuteAction();
        }
    });
}

- (void)provider:(CXProvider *)__unused provider didActivateAudioSession:(AVAudioSession *)audioSession {
    Log(@"[%@] Activated audio session.",  NSStringFromClass([CallKitManager class]));
    QBRTCAudioSession *rtcAudioSession = [QBRTCAudioSession instance];
    [rtcAudioSession audioSessionDidActivate:audioSession];
    // enabling audio now
    rtcAudioSession.audioEnabled = YES;
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    Log(@"[%@] Dectivated audio session.",  NSStringFromClass([CallKitManager class]));
    [[QBRTCAudioSession instance] audioSessionDidDeactivate:audioSession];
    // deinitializing audio session after iOS deactivated it for us
    QBRTCAudioSession *rtcAudioSession = [QBRTCAudioSession instance];
    if (rtcAudioSession.isInitialized) {
        Log(@"[%@] Deinitializing session in CallKit callback.",  NSStringFromClass([CallKitManager class]));
        [rtcAudioSession deinitialize];
    }
}

// MARK: - Helpers

- (CXHandle *)handleForUserIDs:(NSArray *)userIDs {
    if (userIDs.count == 1) {
        QBUUser *user = [self.usersDatasource userWithID:[[userIDs firstObject] integerValue]];
        if (user.phone.length > 0) {
            return [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:user.phone];
        }
    }
    
    return [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:[userIDs componentsJoinedByString:@", "]];
}

static inline void dispatchOnMainThread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)requestTransaction:(CXTransaction *)transaction completion:(void (^)(BOOL))completion {
    [_callController requestTransaction:transaction completion:^(NSError *error) {
        if (error != nil) {
            Log(@"[%@] Error: %@",  NSStringFromClass([CallKitManager class]), error);
        }
        if (completion) {
            completion(error == nil);
        }
    }];
}

@end
