//
//  CallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CallViewController.h"
#import "LocalVideoView.h"
#import "OpponentCollectionViewCell.h"
#import "OpponentsFlowLayout.h"
#import "QBButton.h"
#import "QBButtonsFactory.h"
#import "QBToolBar.h"
#import "QMSoundManager.h"
#import "Settings.h"
#import "SharingViewController.h"
#import "SVProgressHUD.h"
#import "UsersDataSource.h"
#import "QBCore.h"
#import "StatsView.h"
#import "PlaceholderGenerator.h"
#import "RecordSettings.h"
#import "CallKitManager.h"
#import <AVKit/AVKit.h>

static NSString * const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";
static NSString * const kSharingViewControllerIdentifier = @"SharingViewController";

static const NSTimeInterval kRefreshTimeInterval = 1.f;

static NSString * const kUnknownUserLabel = @"?";
static NSString * const kQBRTCRecordingTitle = @"[Recording] ";

@interface CallViewController ()

<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCClientDelegate, QBRTCAudioSessionDelegate, LocalVideoViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet QBToolBar *toolbar;

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;

@property (assign, nonatomic) NSTimeInterval timeDuration;
@property (strong, nonatomic) NSTimer *callTimer;
@property (assign, nonatomic) NSTimer *beepTimer;

@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;
@property (strong, nonatomic) NSMutableDictionary *videoViews;
@property (weak, nonatomic) UIView *zoomedView;

@property (strong, nonatomic) QBButton *dynamicEnable;
@property (strong, nonatomic) QBButton *videoEnabled;
@property (strong, nonatomic) QBButton *audioEnabled;
@property (weak, nonatomic) LocalVideoView *localVideoView;

@property (strong, nonatomic) StatsView *statsView;
@property (assign, nonatomic) BOOL shouldGetStats;

@end

@implementation CallViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[QBRTCClient instance] addDelegate:self];
    [[QBRTCAudioSession instance] addDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
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
    
    [self configureGUI];
    
    Settings *settings = [Settings instance];
    
    if (self.session.opponentsIDs.count == 1
        && settings.recordSettings.isEnabled) {
        // recording calls for p2p 1 to 1
        if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
            
            [self.session.recorder setVideoRecordingRotation:settings.recordSettings.videoRotation];
            [self.session.recorder setVideoRecordingWidth:settings.recordSettings.width
                                                   height:settings.recordSettings.height
                                                  bitrate:[settings.recordSettings estimatedBitrate]
                                                      fps:settings.recordSettings.fps];
        }
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths firstObject];
        NSString *filePath = [NSString stringWithFormat:@"%@/file_%f.mp4", documentPath, [NSDate date].timeIntervalSince1970];
        [self.session.recorder startRecordWithFileURL:[NSURL fileURLWithPath:filePath]];
    }
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
#if !(TARGET_IPHONE_SIMULATOR)
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPostion];
        [self.cameraCapture startSession:nil];
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
#endif
    }
    
    self.view.backgroundColor = self.opponentsCollectionView.backgroundColor =
    [UIColor colorWithRed:0.1465 green:0.1465 blue:0.1465 alpha:1.0];
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:self.session.opponentsIDs.count + 1];
    [users insertObject:Core.currentUser atIndex:0];
    
    for (NSNumber *uID in self.session.opponentsIDs) {
        
        if (Core.currentUser.ID == uID.integerValue) {
            
            QBUUser *initiator = [self.usersDatasource userWithID:self.session.initiatorID.unsignedIntegerValue];
            
            if (!initiator) {
                
                initiator = [QBUUser user];
                initiator.ID = self.session.initiatorID.integerValue;
            }
            
            [users insertObject:initiator atIndex:0];
            
            continue;
        }
        
        QBUUser *user = [self.usersDatasource userWithID:uID.integerValue];
        if (!user) {
            user = [QBUUser user];
            user.ID = uID.integerValue;
        }
        [users insertObject:user atIndex:0];
    }
    
    self.users = users;
    
    BOOL isInitiator = (Core.currentUser.ID == self.session.initiatorID.unsignedIntegerValue);
    isInitiator ? [self startCall] : [self acceptCall];
    
    self.title = @"Connecting...";
    
    if (CallKitManager.isCallKitAvailable
        && [self.session.initiatorID integerValue] == Core.currentUser.ID) {
        [CallKitManager.instance updateCallWithUUID:_callUUID connectingAtDate:[NSDate date]];
    }
}

- (UIView *)videoViewWithOpponentID:(NSNumber *)opponentID {
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        return nil;
    }
    
    if (!self.videoViews) {
        self.videoViews = [NSMutableDictionary dictionary];
    }
    
    id result = self.videoViews[opponentID];
    
    if (Core.currentUser.ID == opponentID.integerValue) {//Local preview
        
        if (!result) {
            
            LocalVideoView *localVideoView = [[LocalVideoView alloc] initWithPreviewlayer:self.cameraCapture.previewLayer];
            self.videoViews[opponentID] = localVideoView;
            localVideoView.delegate = self;
            self.localVideoView = localVideoView;
            
            return localVideoView;
        }
    }
    else {//Opponents
        
        QBRTCRemoteVideoView *remoteVideoView = nil;
        
        QBRTCVideoTrack *remoteVideoTraсk = [self.session remoteVideoTrackWithUserID:opponentID];
        
        if (!result && remoteVideoTraсk) {
            
            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2, 2, 2, 2)];
            remoteVideoView.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.videoViews[opponentID] = remoteVideoView;
            result = remoteVideoView;
        }
        
        [remoteVideoView setVideoTrack:remoteVideoTraсk];
        
        return result;
    }
    
    return result;
}

- (void)startCall {
    //Begin play calling sound
    self.beepTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                      target:self
                                                    selector:@selector(playCallingSound:)
                                                    userInfo:nil
                                                     repeats:YES];
    [self playCallingSound:nil];
    //Start call
    NSDictionary *userInfo = @{@"name" : @"Test",
                               @"url" : @"http.quickblox.com",
                               @"param" : @"\"1,2,3,4\""};
    
    [self.session startCall:userInfo];
}

- (void)acceptCall {
    
    [[QMSoundManager instance] stopAllSounds];
    //Accept call
    NSDictionary *userInfo = @{@"acceptCall" : @"userInfo"};
    [self.session acceptCall:userInfo];
}

- (void)configureGUI {
    
    __weak __typeof(self)weakSelf = self;
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        self.videoEnabled = [QBButtonsFactory videoEnable];
        [self.toolbar addButton:self.videoEnabled action: ^(UIButton *sender) {
            
            weakSelf.session.localMediaStream.videoTrack.enabled ^=1;
            weakSelf.localVideoView.hidden = !weakSelf.session.localMediaStream.videoTrack.enabled;
        }];
    }
    
    self.audioEnabled = [QBButtonsFactory auidoEnable];
    [self.toolbar addButton:self.audioEnabled action: ^(UIButton *sender) {
        
        weakSelf.session.localMediaStream.audioTrack.enabled ^=1;
        weakSelf.session.recorder.microphoneMuted = !weakSelf.session.localMediaStream.audioTrack.enabled;
    }];
    
    [CallKitManager.instance setOnMicrophoneMuteAction:^{
        weakSelf.audioEnabled.pressed ^= 1;
    }];
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        
        self.dynamicEnable = [QBButtonsFactory dynamicEnable];
        [self.toolbar addButton:self.dynamicEnable action:^(UIButton *sender) {
            
            QBRTCAudioDevice device = [QBRTCAudioSession instance].currentAudioDevice;
            
            [QBRTCAudioSession instance].currentAudioDevice =
            device == QBRTCAudioDeviceSpeaker ? QBRTCAudioDeviceReceiver : QBRTCAudioDeviceSpeaker;
        }];
    }
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        [self.toolbar addButton:[QBButtonsFactory screenShare] action: ^(UIButton *sender) {
            
            SharingViewController *sharingVC =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:kSharingViewControllerIdentifier];
            sharingVC.session = weakSelf.session;
            
            // put camera capture on pause
            [weakSelf.cameraCapture stopSession:nil];
            
            [weakSelf.navigationController pushViewController:sharingVC animated:YES];
        }];
    }
    
    [self.toolbar addButton:[QBButtonsFactory decline] action: ^(UIButton *sender) {
        
        [weakSelf.callTimer invalidate];
        weakSelf.callTimer = nil;
        
        if (weakSelf.session.recorder.state == QBRTCRecorderStateActive) {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving record", nil)];
            [weakSelf.session.recorder stopRecord:^(NSURL *file) {
                [SVProgressHUD dismiss];
            }];
        }
        [weakSelf.session hangUp:@{@"hangup" : @"hang up"}];
    }];
    
    [self.toolbar updateItems];
    
    // stats reports view
    _statsView = [[StatsView alloc] initWithFrame:self.view.bounds];
    _statsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _statsView.hidden = YES;
    [self.view addSubview:_statsView];
    
    // add button to enable stats view
    UIBarButtonItem *statsButton = [[UIBarButtonItem alloc] initWithTitle:@"Stats" style:UIBarButtonItemStylePlain target:self action:@selector(updateStatsView)];
    self.navigationItem.rightBarButtonItem = statsButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshVideoViews];
    
    if (self.cameraCapture != nil
        && !self.cameraCapture.hasStarted) {
        // ideally you should always stop capture session
        // when you are leaving controller in any way
        // here we should get its running state back
        [self.cameraCapture startSession:nil];
    }
}

- (void)refreshVideoViews {
    
    for (OpponentCollectionViewCell *viewToRefresh  in self.opponentsCollectionView.visibleCells) {
        id v = viewToRefresh.videoView;
        [viewToRefresh setVideoView:nil];
        [viewToRefresh setVideoView:v];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OpponentCollectionViewCell *reusableCell = [collectionView
                                                dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
                                                forIndexPath:indexPath];
    QBUUser *user = self.users[indexPath.row];
    NSNumber *userID = @(user.ID);
    
    __weak __typeof(self)weakSelf = self;
    [reusableCell setDidPressMuteButton:^(BOOL isMuted) {
        
        QBRTCAudioTrack *audioTrack = [weakSelf.session remoteAudioTrackWithUserID:userID];
        audioTrack.enabled = !isMuted;
    }];
    
    [reusableCell setVideoView:[self videoViewWithOpponentID:userID]];
    reusableCell.connectionState = [self.session connectionStateForUser:userID];
    
    if (user.ID != [QBSession currentSession].currentUser.ID) {
        
        NSString *title = user.fullName ?: kUnknownUserLabel;
        reusableCell.placeholderImageView.image = [PlaceholderGenerator placeholderWithSize:reusableCell.placeholderImageView.bounds.size title:title];
    }
    
    return reusableCell;
}

#pragma mark - Transition to size

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [self refreshVideoViews];
        
    } completion:nil];
}

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {
    
    QBUUser *user = [self.usersDatasource userWithID:userID.unsignedIntegerValue];
    
    if (!user) {
        user = [QBUUser user];
        user.ID = userID.unsignedIntegerValue;
    }
    NSUInteger idx = [self.users indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

- (void)performUpdateUserID:(NSNumber *)userID block:(void(^)(OpponentCollectionViewCell *cell))block {
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    OpponentCollectionViewCell *cell = (id)[self.opponentsCollectionView cellForItemAtIndexPath:indexPath];
    block(cell);
}

#pragma mark - Statistic

- (void)updateStatsView {
    self.shouldGetStats ^= 1;
    self.statsView.hidden ^= 1;
}

#pragma mark - QBRTCClientDelegate

- (void)session:(QBRTCSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
    
    NSString *result = [report statsString];
    NSLog(@"%@", result);
    
    // send stats to stats view if needed
    if (_shouldGetStats) {
        [_statsView setStats:result];
        [self.view setNeedsLayout];
    }
}

/**
 * Called in case when you are calling to user, but he hasn't answered
 */
- (void)session:(QBRTCSession *)session userDoesNotRespond:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 * Called in case when opponent has rejected you call
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when opponent hung up
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when receive remote video track from opponent
 */

- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            
            QBRTCRemoteVideoView *opponentVideoView = (id)[self videoViewWithOpponentID:userID];
            [cell setVideoView:opponentVideoView];
        }];
    }
}

/**
 *  Called in case when connection is established with opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        if (self.beepTimer) {
            
            [self.beepTimer invalidate];
            self.beepTimer = nil;
            [[QMSoundManager instance] stopAllSounds];
        }
        
        if (!self.callTimer) {
            
            if (CallKitManager.isCallKitAvailable
                && [self.session.initiatorID integerValue] == Core.currentUser.ID) {
                [CallKitManager.instance updateCallWithUUID:_callUUID connectedAtDate:[NSDate date]];
            }
            
            self.callTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval
                                                              target:self
                                                            selector:@selector(refreshCallTime:)
                                                            userInfo:nil
                                                             repeats:YES];
        }
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when connection state changed
 */
- (void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
            [self.videoViews removeObjectForKey:userID];
            [cell setVideoView:nil];
        }];
    }
}

/**
 *  Called in case when disconnected from opponent
 */
- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when disconnected by timeout
 */
- (void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when connection failed with user
 */
- (void)session:(QBRTCSession *)session connectionFailedWithUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when session will close
 */
- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session) {
        
        if (CallKitManager.isCallKitAvailable) {
            [CallKitManager.instance endCallWithUUID:_callUUID completion:nil];
        }
        
        if (self.session.recorder.state == QBRTCRecorderStateActive) {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving record", nil)];
            [self.session.recorder stopRecord:^(NSURL *file) {
                [SVProgressHUD dismiss];
            }];
        }
        
        [self.cameraCapture stopSession:nil];
        
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        if (audioSession.isInitialized
            && ![audioSession audioSessionIsActivatedOutside:[AVAudioSession sharedInstance]]) {
            NSLog(@"Deinitializing QBRTCAudioSession in CallViewController.");
            [audioSession deinitialize];
        }
        
        if (self.beepTimer) {
            
            [self.beepTimer invalidate];
            self.beepTimer = nil;
            [[QMSoundManager instance] stopAllSounds];
        }
        
        [self.callTimer invalidate];
        self.callTimer = nil;
        
        self.toolbar.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            
            self.toolbar.alpha = 0.4;
        }];
        
        self.title = [NSString stringWithFormat:@"End - %@", [self stringWithTimeDuration:self.timeDuration]];
    }
}

#pragma mark - QBRTCAudioSessionDelegate

- (void)audioSession:(QBRTCAudioSession *)audioSession didChangeCurrentAudioDevice:(QBRTCAudioDevice)updatedAudioDevice {
    
    BOOL isSpeaker = updatedAudioDevice == QBRTCAudioDeviceSpeaker;
    if (self.dynamicEnable.pressed != isSpeaker) {
        
        self.dynamicEnable.pressed = isSpeaker;
    }
}

#pragma mark - Timers actions

- (void)playCallingSound:(id)sender {
    
    [QMSoundManager playCallingSound];
}

- (void)refreshCallTime:(NSTimer *)sender {
    
    self.timeDuration += kRefreshTimeInterval;
    NSString *extraTitle = @"";
    if (self.session.recorder.state == QBRTCRecorderStateActive) {
        extraTitle = kQBRTCRecordingTitle;
    }
    self.title = [NSString stringWithFormat:@"%@Call time - %@", extraTitle, [self stringWithTimeDuration:self.timeDuration]];
}

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {
    
    NSInteger minutes = timeDuration / 60;
    NSInteger seconds = (NSInteger)timeDuration % 60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    return timeStr;
}

- (void)localVideoView:(LocalVideoView *)localVideoView pressedSwitchButton:(UIButton *)sender {
    
    AVCaptureDevicePosition position = self.cameraCapture.position;
    AVCaptureDevicePosition newPosition = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    if ([self.cameraCapture hasCameraForPosition:newPosition]) {
        
        CATransition *animation = [CATransition animation];
        animation.duration = .75f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        if (position == AVCaptureDevicePositionFront) {
            
            animation.subtype = kCATransitionFromRight;
        }
        else if(position == AVCaptureDevicePositionBack) {
            
            animation.subtype = kCATransitionFromLeft;
        }
        
        [localVideoView.superview.layer addAnimation:animation forKey:nil];
        self.cameraCapture.position = newPosition;
    }
}

@end
