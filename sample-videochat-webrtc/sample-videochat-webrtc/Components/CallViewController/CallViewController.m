//
//  CallViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CallViewController.h"
#import "LocalVideoView.h"
#import "OpponentCollectionViewCell.h"
#import "OpponentsFlowLayout.h"
#import "Button.h"
#import "ButtonsFactory.h"
#import "ToolBar.h"
#import "SoundManager.h"
#import "Settings.h"
#import "SharingViewController.h"
#import "SVProgressHUD.h"
#import "UsersDataSource.h"
#import "StatsView.h"
#import "PlaceholderGenerator.h"
#import "ZoomedView.h"
#import "CallKitManager.h"
#import "Profile.h"
#import "User.h"
#import "Log.h"
#import "Reachability.h"

static NSString * const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";
static NSString * const kSharingViewControllerIdentifier = @"SharingViewController";

static const NSTimeInterval kRefreshTimeInterval = 1.0f;

static NSString * const kUnknownUserLabel = @"?";

@interface CallViewController ()

<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCClientDelegate, QBRTCAudioSessionDelegate, LocalVideoViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet ToolBar *toolbar;
@property (strong, nonatomic) NSMutableArray *users;

@property (assign, nonatomic) NSTimeInterval timeDuration;
@property (strong, nonatomic) NSTimer *callTimer;
@property (assign, nonatomic) NSTimer *beepTimer;

@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;
@property (strong, nonatomic) NSMutableDictionary *videoViews;

@property (strong, nonatomic) Button *dynamicEnable;
@property (strong, nonatomic) Button *videoEnabled;
@property (strong, nonatomic) Button *audioEnabled;
@property (weak, nonatomic) LocalVideoView *localVideoView;

@property (strong, nonatomic) StatsView *statsView;
@property (assign, nonatomic) BOOL shouldGetStats;
@property (strong, nonatomic) NSNumber *statsUserID;

@property (strong, nonatomic) ZoomedView *zoomedView;
@property (weak, nonatomic) OpponentCollectionViewCell *originCell;

@property (strong, nonatomic) UIBarButtonItem *statsItem;

@end

@implementation CallViewController

// MARK: - Life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            
            if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
                // setting mode to video chat to enable airplay audio and speaker only
                configuration.mode = AVAudioSessionModeVideoChat;
            }
        }];
    }
    self.videoViews = [NSMutableDictionary dictionary];
    self.users = [NSMutableArray array];
    [self configureGUI];
    
    
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        
#if TARGET_OS_SIMULATOR
        Log(@"[%@] TARGET_OS_SIMULATOR", NSStringFromClass([CallViewController class]));
#else
        Settings *settings = [Settings instance];
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPostion];
        [self.cameraCapture startSession:nil];
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
#endif
    }
    
    self.view.backgroundColor = self.opponentsCollectionView.backgroundColor =
    [UIColor colorWithRed:0.1465 green:0.1465 blue:0.1465 alpha:1.0];
    
    Profile *profile = [[Profile alloc] init];
    User *me = [[User alloc] initWithID:profile.ID fullName:profile.fullName];
    
    [self.users insertObject:me atIndex:0];
    
    BOOL isInitiator = (profile.ID == self.session.initiatorID.unsignedIntegerValue);
    isInitiator ? [self startCall] : [self acceptCall];
    
    self.title = @"Connecting...";
    
    if (self.session.initiatorID.unsignedIntegerValue == profile.ID) {
        [CallKitManager.instance updateCallWithUUID:_callUUID connectingAtDate:[NSDate date]];
    }
    
    [[QBRTCClient instance] addDelegate:self];
    [[QBRTCAudioSession instance] addDelegate:self];
}

- (void)configureGUI {
    
    __weak __typeof(self)weakSelf = self;
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        self.videoEnabled = [ButtonsFactory videoEnable];
        [self.toolbar addButton:self.videoEnabled action: ^(UIButton *sender) {
            
            weakSelf.session.localMediaStream.videoTrack.enabled ^=1;
            weakSelf.localVideoView.hidden = !weakSelf.session.localMediaStream.videoTrack.enabled;
        }];
    }
    
    self.audioEnabled = [ButtonsFactory auidoEnable];
    [self.toolbar addButton:self.audioEnabled action: ^(UIButton *sender) {
        
        weakSelf.session.localMediaStream.audioTrack.enabled ^=1;
        weakSelf.session.recorder.microphoneMuted = !weakSelf.session.localMediaStream.audioTrack.enabled;
    }];
    
    [CallKitManager.instance setOnMicrophoneMuteAction:^{
        weakSelf.audioEnabled.pressed ^= 1;
        weakSelf.session.recorder.microphoneMuted = weakSelf.audioEnabled.pressed;
    }];
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        
        self.dynamicEnable = [ButtonsFactory dynamicEnable];
        [self.toolbar addButton:self.dynamicEnable action:^(UIButton *sender) {
            
            QBRTCAudioDevice device = [QBRTCAudioSession instance].currentAudioDevice;
            
            [QBRTCAudioSession instance].currentAudioDevice =
            device == QBRTCAudioDeviceSpeaker ? QBRTCAudioDeviceReceiver : QBRTCAudioDeviceSpeaker;
        }];
    }
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        [self.toolbar addButton:[ButtonsFactory screenShare] action: ^(UIButton *sender) {
            
            SharingViewController *sharingVC =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:kSharingViewControllerIdentifier];
            sharingVC.session = weakSelf.session;
            
            // put camera capture on pause
            [weakSelf.cameraCapture stopSession:nil];
            
            [weakSelf.navigationController pushViewController:sharingVC animated:YES];
        }];
    }
    
    [self.toolbar addButton:[ButtonsFactory decline] action: ^(UIButton *sender) {
        
        [weakSelf.callTimer invalidate];
        weakSelf.callTimer = nil;
        
        [weakSelf.session hangUp:@{@"hangup" : @"hang up"}];
        [CallKitManager.instance endCallWithUUID:weakSelf.callUUID completion:^{
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        }];
    }];
    
    [self.toolbar updateItems];
    
    // stats view
    _statsView = prepareSubview(self.view, [StatsView class]);
    [_statsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateStatsState)]];
    
    // add button to enable stats view
    self.statsItem = [[UIBarButtonItem alloc] initWithTitle:@"Stats"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(updateStatsView)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //MARK: - Reachability
    void (^updateConnectionStatus)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        if (status == QBNetworkStatusNotReachable) {
            [self cancelCallAlert];
        }
    };
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        updateConnectionStatus(status);
    };
    updateConnectionStatus(Reachability.instance.networkStatus);
    
    if (!self.cameraCapture) {
        Settings *settings = [Settings instance];
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPostion];
    }
    
    if (self.cameraCapture != nil
        && !self.cameraCapture.hasStarted) {
        // ideally you should always stop capture session
        // when you are leaving controller in any way
        // here we should get its running state back
        [self.cameraCapture startSession:nil];
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
    }
    self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
    [self reloadContent];
}

- (void)cancelCallAlert {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please check your Internet connection", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [CallKitManager.instance endCallWithUUID:self.callUUID completion:^{
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:NO completion:^{
    }];
}

- (void)reloadContent {
    for (UIView *videoView in [self.videoViews allValues]) {
        [videoView removeFromSuperview];
    }
    [self.opponentsCollectionView reloadData];
}

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
    User *conferenceUser = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    NSUInteger idx = [self.users indexOfObject:conferenceUser];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

// MARK: - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        return self.users.count;
    } else {
        NSInteger count = self.statsUserID != nil ? 1 : self.users.count;
        return count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OpponentCollectionViewCell *cell = [collectionView
                                        dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
                                        forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        if (self.statsUserID) {
            NSIndexPath *selectedIndexPath = [self indexPathAtUserID:self.statsUserID];
            index = selectedIndexPath.row;
        }
    }
    
    User *user = self.users[index];
    QBRTCAudioTrack *audioTrack = [self.session remoteAudioTrackWithUserID:user.ID];
    cell.muteButton.selected = !audioTrack.enabled;
    
    __weak __typeof(self)weakSelf = self;
    [cell setDidPressMuteButton:^(BOOL isMuted) {
        QBRTCAudioTrack *audioTrack = [weakSelf.session remoteAudioTrackWithUserID:user.ID];
        audioTrack.enabled = !isMuted;
    }];
    
    UIView *videoView = [self userViewWithUserID:user.ID];
    if (videoView) {
        [cell setVideoView: videoView];
    }
    
    cell.name = nil;
    cell.connectionState = QBRTCConnectionStateUnknown;
    
    if (user.ID.unsignedIntegerValue != [QBSession currentSession].currentUser.ID) {
        
        NSString *title = user.fullName ?: kUnknownUserLabel;
        cell.name = title;
        cell.nameColor = [PlaceholderGenerator colorForString:title];
        if (user.bitrate > 0.0) {
            cell.bitrateString = [NSString stringWithFormat:@"%.0f kbits/sec", user.bitrate* 1e-3];
        } else {
            cell.bitrateString = @"";
        }
        cell.connectionState = user.connectionState;
        
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    User *user = self.users[indexPath.item];
    if (user.ID == self.session.currentUserID) {
        // do not zoom local video view
        return;
    }
    
    if (_session.conferenceType == QBRTCConferenceTypeAudio) {
        // just show stats on click if in audio call
        self.statsUserID = user.ID;
        [self updateStatsView];
    } else {
        if (self.statsUserID) {
            [self unzoomUser];
        } else {
            if (user.connectionState == QBRTCConnectionStateConnected) {
                [self zoomUserWithUserID:user.ID];
            }
        }
    }
}

//MARK: - Internal Methods
- (void)zoomUserWithUserID:(NSNumber *)userID {
    self.statsUserID = userID;
    [self reloadContent];
    self.navigationItem.rightBarButtonItem = self.statsItem;
}

- (void)unzoomUser {
    self.statsUserID = nil;
    [self reloadContent];
    self.navigationItem.rightBarButtonItem = nil;
}

// MARK: - Transition to size

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [self reloadContent];
        
    } completion:nil];
}

// MARK: - QBRTCClientDelegate
- (void)session:(__kindof QBRTCBaseSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
    if (session == self.session) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
        User *user = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
        if (user.connectionState == QBRTCConnectionStateConnected
            && report.videoReceivedBitrateTracker.bitrate > 0) {
            user.bitrate = report.videoReceivedBitrateTracker.bitrate;
        }
        [self reloadContent];
        
        if ([_statsUserID isEqualToNumber:userID]) {
            
            NSString *result = [NSString stringWithFormat:@"User: %@\n%@", user.fullName ?: userID,[report statsString]];
            
            // send stats to stats view if needed
            if (_shouldGetStats) {
                [_statsView setStats:result];
                [self.view setNeedsLayout];
            }
        }
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(nonnull NSNumber *)userID {
    
    if (session == self.session) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
        User *user = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
        
        if (user) {
            user.connectionState = state;
        } else {
            QBUUser *qbUser = [self.usersDatasource userWithID:userID.unsignedIntegerValue];
            User *user = [[User alloc] initWithID:qbUser.ID fullName:qbUser.fullName];
            user.connectionState = state;
            
            if (![self.users containsObject:user] || user.connectionState == QBRTCConnectionStateConnected) {
                [self.users insertObject:user atIndex:0];
            }
            
        }
        [self reloadContent];
    }
}

/**
 *  Called in case when receive remote video track from opponent
 */

- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self reloadContent];
    }
}

/**
 *  Called in case when connection is established with opponent
 */

- (void)session:(__kindof QBRTCBaseSession *)session connectedToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        if (self.beepTimer) {
            
            [self.beepTimer invalidate];
            self.beepTimer = nil;
            [[SoundManager instance] stopAllSounds];
        }
        
        if (!self.callTimer) {
            Profile *profile = [[Profile alloc] init];
            
            if   ([self.session.initiatorID integerValue] == profile.ID) {
                [CallKitManager.instance updateCallWithUUID:_callUUID connectedAtDate:[NSDate date]];
            }
            
            self.callTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval
                                                              target:self
                                                            selector:@selector(refreshCallTime:)
                                                            userInfo:nil
                                                             repeats:YES];
        }
    }
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if ([userInfo[@"hangup"] isEqualToString:@"hang up"]) {
        if (self.statsUserID == userID) {
            [self unzoomUser];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
        User *user = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
        if (user.connectionState == QBRTCConnectionStateConnected) {
            return;
        }
        
        UIView *videoView = self.videoViews[userID];
        
        [videoView removeFromSuperview];
        [self.videoViews removeObjectForKey:userID];
        
        
        QBRTCRemoteVideoView *remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, 2.0f, 2.0f)];
        remoteVideoView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoViews[userID] = remoteVideoView;
        
        [self reloadContent];
    }
}

/**
 *  Called in case when connection state changed
 */
- (void)session:(__kindof QBRTCBaseSession *)session connectionClosedForUser:(NSNumber *)userID {
    
    if (self.statsUserID == userID) {
        [self unzoomUser];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
    User *user = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    if (user.connectionState == QBRTCConnectionStateConnected) {
        return;
    }
    
    UIView *videoView = self.videoViews[userID];
    
    [videoView removeFromSuperview];
    [self.videoViews removeObjectForKey:userID];
    
    
    QBRTCRemoteVideoView *remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, 2.0f, 2.0f)];
    remoteVideoView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoViews[userID] = remoteVideoView;
    
    [self reloadContent];
}

/**
 *  Called in case when session will close
 */
- (void)sessionDidClose:(__kindof QBRTCBaseSession *)session {
    
    if (session == self.session) {
        
        [CallKitManager.instance endCallWithUUID:_callUUID completion:nil];
        
        [self.cameraCapture stopSession:nil];
        
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        if (audioSession.isInitialized
            && ![audioSession audioSessionIsActivatedOutside:[AVAudioSession sharedInstance]]) {
            Log(@"[%@] Deinitializing QBRTCAudioSession", NSStringFromClass([CallViewController class]));
            [audioSession deinitialize];
        }
        
        if (self.beepTimer) {
            
            [self.beepTimer invalidate];
            self.beepTimer = nil;
            [[SoundManager instance] stopAllSounds];
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

// MARK: - QBRTCAudioSessionDelegate

- (void)audioSession:(QBRTCAudioSession *)audioSession didChangeCurrentAudioDevice:(QBRTCAudioDevice)updatedAudioDevice {
    
    BOOL isSpeaker = updatedAudioDevice == QBRTCAudioDeviceSpeaker;
    if (self.dynamicEnable.pressed != isSpeaker) {
        self.dynamicEnable.pressed = isSpeaker;
    }
}

// MARK: - Timers actions

- (void)playCallingSound:(id)sender {
    [SoundManager playCallingSound];
}

- (void)refreshCallTime:(NSTimer *)sender {
    
    self.timeDuration += kRefreshTimeInterval;
    NSString *extraTitle = @"";
    
    self.title = [NSString stringWithFormat:@"%@Call time - %@", extraTitle, [self stringWithTimeDuration:self.timeDuration]];
}

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {
    NSInteger hours = timeDuration / 3600;
    NSInteger minutes = timeDuration / 60;
    NSInteger seconds = (NSInteger)timeDuration % 60;
    
    NSString *timeStr = @"";
    
    if (hours > 0) {
        NSInteger minutes = (timeDuration - 3600 * hours) / 60;
        timeStr = [NSString stringWithFormat:@"%ld:%ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
    return timeStr;
}

// MARK: - LocalVideoViewDelegate
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

// MARK: - Actions
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
    
    [[SoundManager instance] stopAllSounds];
    //Accept call
    NSDictionary *userInfo = @{@"acceptCall" : @"userInfo"};
    [self.session acceptCall:userInfo];
}

- (void)updateStatsView {
    self.shouldGetStats = !self.shouldGetStats;
    self.statsView.hidden = !self.statsView.hidden;
}

- (void)updateStatsState {
    [self updateStatsView];
}

// MARK: - Helpers

static inline __kindof UIView *prepareSubview(UIView *view, Class subviewClass) {
    
    UIView *subview = [[subviewClass alloc] initWithFrame:view.bounds];
    subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    subview.hidden = YES;
    [view addSubview:subview];
    return subview;
}

- (UIView *)userViewWithUserID:(NSNumber *)userID {
    id result = self.videoViews[userID];
    if (self.videoViews[userID]) {
        return self.videoViews[userID];
    }
    
    Profile *profile = [[Profile alloc] init];
    if (profile.ID == userID.unsignedIntegerValue && self.session.conferenceType == QBRTCConferenceTypeVideo) {//Local preview
        
        if (!result) {
            LocalVideoView *localVideoView = [[LocalVideoView alloc] initWithPreviewlayer:self.cameraCapture.previewLayer];
            self.videoViews[userID] = localVideoView;
            localVideoView.delegate = self;
            self.localVideoView = localVideoView;
            
            return localVideoView;
        }
    } else {//Opponents
        
        QBRTCRemoteVideoView *remoteVideoView = nil;
        
        QBRTCVideoTrack *remoteVideoTraсk = [self.session remoteVideoTrackWithUserID:userID];
        
        if (!result && remoteVideoTraсk) {
            
            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, 2.0f, 2.0f)];
            remoteVideoView.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.videoViews[userID] = remoteVideoView;
            [remoteVideoView setVideoTrack:remoteVideoTraсk];
            
            return remoteVideoView;
        }
    }
    
    return result;
}

@end
