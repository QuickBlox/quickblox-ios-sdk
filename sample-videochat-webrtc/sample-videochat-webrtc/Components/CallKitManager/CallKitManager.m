//
//  CallKitManager.m
//  sample-videochat-webrtc-old
//
//  Created by Vitaliy Gorbachov on 10/9/17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import "CallKitManager.h"

#import <CallKit/CallKit.h>

#import "UsersDataSource.h"

static const NSInteger QBDefaultMaximumCallsPerCallGroup = 1;
static const NSInteger QBDefaultMaximumCallGroups = 1;

@interface CallKitManager () <CXProviderDelegate>
{
    BOOL _callStarted;
}

@property (strong, nonatomic) CXProvider *provider;
@property (strong, nonatomic) CXCallController *callController;
@property (copy, nonatomic) dispatch_block_t actionCompletionBlock;
@property (copy, nonatomic) dispatch_block_t onAcceptActionBlock;

@property (weak, nonatomic) QBRTCSession *session;

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
    config.maximumCallsPerCallGroup = QBDefaultMaximumCallsPerCallGroup;
    config.maximumCallGroups = QBDefaultMaximumCallGroups;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypeGeneric), @(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);
    config.ringtoneSound = @"ringtone.wav";
    return config;
}

+ (BOOL)isCallKitAvailable {
    static BOOL callKitAvailable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_IPHONE_SIMULATOR
        callKitAvailable = NO;
#else
        callKitAvailable = [UIDevice currentDevice].systemVersion.integerValue >= 10;
#endif
    });
    return callKitAvailable;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        CXProviderConfiguration *configuration = [CallKitManager configuration];
        self.provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [self.provider setDelegate:self queue:nil];
        
        self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    }
    return self;
}

// MARK: - Call management

- (void)startCallWithUserIDs:(NSArray *)userIDs session:(QBRTCSession *)session uuid:(NSUUID *)uuid {
    _session = session;
    NSString *contactIdentifier = nil;
    CXHandle *handle = [self handleForUserIDs:userIDs outCallerName:&contactIdentifier];
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
        
        [_provider reportCallWithUUID:uuid updated:update];
    }];
}

- (void)endCallWithUUID:(NSUUID *)uuid completion:(dispatch_block_t)completion {
    if (_session == nil) {
        return;
    }
    
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    
    dispatchOnMainThread(^{
        [self requestTransaction:transaction completion:nil];
    });
    
    if (completion != nil) {
        _actionCompletionBlock = completion;
    }
}

- (void)reportIncomingCallWithUserIDs:(NSArray *)userIDs session:(QBRTCSession *)session uuid:(NSUUID *)uuid onAcceptAction:(dispatch_block_t)onAcceptAction completion:(void (^)(BOOL))completion {
    NSLog(@"[CallKitManager] Report incoming call %@", uuid);
    
    if (_session != nil) {
        return;
    }
    
    _session = session;
    _onAcceptActionBlock = onAcceptAction;
    
    NSString *callerName = nil;
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [self handleForUserIDs:userIDs outCallerName:&callerName];
    update.localizedCallerName = callerName;
    update.supportsHolding = NO;
    update.supportsGrouping = NO;
    update.supportsUngrouping = NO;
    update.supportsDTMF = NO;
    update.hasVideo = session.conferenceType == QBRTCConferenceTypeVideo;
    
    NSLog(@"[CallKitManager] Activating audio session.");
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

            if (_session.conferenceType == QBRTCConferenceTypeVideo) {
                // setting mode to video chat to enable airplay audio and speaker only
                configuration.mode = AVAudioSessionModeVideoChat;
            }
        }];
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
    
    dispatchOnMainThread(^{
        [_session startCall:nil];
        _callStarted = YES;
        [action fulfill];
    });
}

- (void)provider:(CXProvider *)__unused provider performAnswerCallAction:(CXAnswerCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    if ([UIDevice currentDevice].systemVersion.integerValue == 10) {
        // Workaround for webrtc on ios 10, because first incoming call does not have audio
        // due to incorrect category: AVAudioSessionCategorySoloAmbient
        // webrtc need AVAudioSessionCategoryPlayAndRecord
        NSError *err = nil;
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&err]) {
            NSLog(@"[CallKitManager] Error setting category for webrtc workaround.");
        }
    }
    
    dispatchOnMainThread(^{
        [_session acceptCall:nil];
        _callStarted = YES;
        [action fulfill];
        
        if (_onAcceptActionBlock != nil) {
            _onAcceptActionBlock();
            _onAcceptActionBlock = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performEndCallAction:(CXEndCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    QBRTCSession *session = _session;
    _session = nil;
    
    dispatchOnMainThread(^{
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        audioSession.audioEnabled = NO;
        audioSession.useManualAudio = NO;
        
        if (_callStarted) {
            [session hangUp:nil];
            _callStarted = NO;
        }
        else {
            [session rejectCall:nil];
        }
        
        [action fulfillWithDateEnded:[NSDate date]];
        
        if (_actionCompletionBlock != nil) {
            _actionCompletionBlock();
            _actionCompletionBlock = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    dispatchOnMainThread(^{
        _session.localMediaStream.audioTrack.enabled = !action.isMuted;
        [action fulfill];
        
        if (_onMicrophoneMuteAction != nil) {
            _onMicrophoneMuteAction();
        }
    });
}

- (void)provider:(CXProvider *)__unused provider didActivateAudioSession:(AVAudioSession *)audioSession {
    NSLog(@"[CallKitManager] Activated audio session.");
    QBRTCAudioSession *rtcAudioSession = [QBRTCAudioSession instance];
    [rtcAudioSession audioSessionDidActivate:audioSession];
    // enabling audio now
    rtcAudioSession.audioEnabled = YES;
    // enabling local mic recording in recorder (if recorder is active) as of interruptions are over now
    _session.recorder.localAudioEnabled = YES;
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    NSLog(@"[CallKitManager] Dectivated audio session.");
    [[QBRTCAudioSession instance] audioSessionDidDeactivate:audioSession];
    // deinitializing audio session after iOS deactivated it for us
    QBRTCAudioSession *session = [QBRTCAudioSession instance];
    if (session.isInitialized) {
        NSLog(@"Deinitializing session in CallKit callback.");
        [session deinitialize];
    }
}

// MARK: - Helpers

- (CXHandle *)handleForUserIDs:(NSArray *)userIDs outCallerName:(NSString **)outCallerName {
    // handle user from whatever database here
    if (outCallerName != NULL) {
        NSMutableArray *opponentNames = [NSMutableArray arrayWithCapacity:userIDs.count];
        for (NSNumber *userID in userIDs) {
            QBUUser *user = [self.usersDatasource userWithID:[userID integerValue]];
            [opponentNames addObject:user.fullName ?: [NSString stringWithFormat:@"%tu", userID]];
        }
        *outCallerName = [opponentNames componentsJoinedByString:@", "];
    }
    
    if (userIDs.count == 1) {
        QBUUser *user = [self.usersDatasource userWithID:[[userIDs firstObject] integerValue]];
        if (user.phone.length > 0) {
            return [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:user.phone];
        }
    }
    
    return [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:[userIDs componentsJoinedByString:@", "]];
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
            NSLog(@"[CallKitManager] Error: %@", error);
        }
        if (completion != nil) {
            completion(error == nil);
        }
    }];
}

@end
