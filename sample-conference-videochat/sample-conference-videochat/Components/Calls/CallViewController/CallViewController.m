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
#import "Settings.h"
#import "QBCore.h"
#import "StatsView.h"
#import "PlaceholderGenerator.h"
#import "UsersDataSource.h"
#import "SVProgressHUD.h"
#import "AddUsersViewController.h"
#import "ZoomedView.h"

typedef NS_ENUM(NSUInteger, CallViewControllerState) {
    CallViewControllerStateDisconnected,
    CallViewControllerStateConnecting,
    CallViewControllerStateConnected,
    CallViewControllerStateDisconnecting
};

static NSString * const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";
static NSString * const kUnknownUserLabel = @"Unknown user";
static NSString * const kUsersSegue = @"PresentUsersViewController";

@interface CallViewController ()
<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCAudioSessionDelegate, QBRTCConferenceClientDelegate, LocalVideoViewDelegate>
{
    BOOL _didStartPlayAndRecord;
}

@property (weak, nonatomic) QBRTCConferenceSession *session;

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet QBToolBar *toolbar;
@property (strong, nonatomic) NSMutableArray *users;

@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;
@property (strong, nonatomic) NSMutableDictionary *videoViews;

@property (strong, nonatomic) QBButton *dynamicEnable;
@property (strong, nonatomic) QBButton *videoEnabled;
@property (weak, nonatomic) LocalVideoView *localVideoView;

@property (strong, nonatomic) StatsView *statsView;
@property (assign, nonatomic) BOOL shouldGetStats;
@property (strong, nonatomic) NSNumber *statsUserID;

@property (strong, nonatomic) ZoomedView *zoomedView;
@property (weak, nonatomic) OpponentCollectionViewCell *originCell;

@property (assign, nonatomic) CallViewControllerState state;
@property (assign, nonatomic) BOOL muteAudio;
@property (assign, nonatomic) BOOL muteVideo;

@property (strong, nonatomic) UIBarButtonItem *statsItem;
@property (strong, nonatomic) UIBarButtonItem *addUsersItem;

@end

@implementation CallViewController

// MARK: Life cycle

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[QBRTCConferenceClient instance] addDelegate:self];
    [[QBRTCAudioSession instance] addDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // creating session
    self.session = [[QBRTCConferenceClient instance] createSessionWithChatDialogID:_chatDialog.ID conferenceType:_conferenceType > 0 ? _conferenceType : QBRTCConferenceTypeVideo];
    
    if (_conferenceType > 0) {
        self.users = [@[Core.currentUser] mutableCopy];
    }
    else {
        self.users = [[NSMutableArray alloc] init];
    }
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo
        && _conferenceType > 0) {
#if !(TARGET_IPHONE_SIMULATOR)
        Settings *settings = Settings.instance;
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPostion];
        [self.cameraCapture startSession:nil];
#endif
    }
    
    [self configureGUI];
    
    self.view.backgroundColor = self.opponentsCollectionView.backgroundColor =
    [UIColor colorWithRed:0.1465 green:0.1465 blue:0.1465 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [SVProgressHUD showWithStatus:@"MEMORY WARNING: leaving out of call"];
    self.state = CallViewControllerStateDisconnecting;
    [self.session leave];
}

- (void)configureGUI {
    
    __weak __typeof(self)weakSelf = self;
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo
        && _conferenceType > 0) {
        self.videoEnabled = [QBButtonsFactory videoEnable];
        [self.toolbar addButton:self.videoEnabled action: ^(UIButton *sender) {
            
            weakSelf.muteVideo ^= 1;
            weakSelf.localVideoView.hidden = weakSelf.muteVideo;
        }];
    }
    
    if (_conferenceType > 0) {
        [self.toolbar addButton:[QBButtonsFactory auidoEnable] action: ^(UIButton *sender) {
            
            weakSelf.muteAudio ^= 1;
        }];
    }
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        
        self.dynamicEnable = [QBButtonsFactory dynamicEnable];
        self.dynamicEnable.pressed = YES;
        [self.toolbar addButton:self.dynamicEnable action:^(UIButton *sender) {
            
            QBRTCAudioDevice device = [QBRTCAudioSession instance].currentAudioDevice;
            
            [QBRTCAudioSession instance].currentAudioDevice =
            device == QBRTCAudioDeviceSpeaker ? QBRTCAudioDeviceReceiver : QBRTCAudioDeviceSpeaker;
        }];
    }
    
    [self.toolbar updateItems];
    
    // zoomed view
    _zoomedView = prepareSubview(self.view, [ZoomedView class]);
    [_zoomedView setDidTapView:^(ZoomedView *zoomedView) {
        [weakSelf unzoomVideoView];
    }];
    // stats view
    _statsView = prepareSubview(self.view, [StatsView class]);
    
    // add button to enable stats view
    self.statsItem = [[UIBarButtonItem alloc] initWithTitle:@"Stats"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(updateStatsView)];
    self.addUsersItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(pushAddUsersToRoomScreen)];
    
    self.state = CallViewControllerStateConnecting;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Leave"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(leaveFromRoom)];
    
    self.navigationItem.rightBarButtonItem = self.addUsersItem;
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

// MARK: UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OpponentCollectionViewCell *reusableCell = [collectionView
                                                dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
                                                forIndexPath:indexPath];
    
    QBUUser *user = self.users[indexPath.row];
    __weak __typeof(self)weakSelf = self;
    [reusableCell setDidPressMuteButton:^(BOOL isMuted) {
        QBRTCAudioTrack *audioTrack = [weakSelf.session remoteAudioTrackWithUserID:@(user.ID)];
        audioTrack.enabled = !isMuted;
    }];
    
    [reusableCell setVideoView:[self videoViewWithOpponentID:@(user.ID)]];
    
    if (user.ID != [QBSession currentSession].currentUser.ID) {
        // label for user
        NSString *title = user.fullName ?: kUnknownUserLabel;
        reusableCell.name = title;
        reusableCell.nameColor = [PlaceholderGenerator colorForString:title];
        // mute button
        reusableCell.isMuted = NO;
        // state
        reusableCell.connectionState = QBRTCConnectionStateNew;
    }
    
    return reusableCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = self.users[indexPath.item];
    if (user.ID == self.session.currentUserID.unsignedIntegerValue) {
        // do not zoom local video view
        return;
    }
    
    OpponentCollectionViewCell *videoCell = (OpponentCollectionViewCell *)[self.opponentsCollectionView cellForItemAtIndexPath:indexPath];
    UIView *videoView = videoCell.videoView;
    
    if (videoView != nil) {
        videoCell.videoView = nil;
        self.originCell = videoCell;
        _statsUserID = @(user.ID);
        [self zoomVideoView:videoView];
    }
}

// MARK: Transition to size

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [self refreshVideoViews];
        
    } completion:nil];
}

// MARK: QBRTCBaseClientDelegate

- (void)session:(__kindof QBRTCBaseSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            if (cell.connectionState == QBRTCConnectionStateConnected
                && report.videoReceivedBitrateTracker.bitrate > 0) {
                [cell setBitrate:report.videoReceivedBitrateTracker.bitrate];
            }
        }];
        
        if ([_statsUserID isEqualToNumber:userID]) {
            
            NSString *result = [report statsString];
            NSLog(@"%@", result);
            
            // send stats to stats view if needed
            if (_shouldGetStats) {
                
                [_statsView setStats:result];
                [self.view setNeedsLayout];
            }
        }
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session startedConnectingToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        // adding user to the collection
        [self addToCollectionUserWithID:userID];
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session connectionClosedForUser:(NSNumber *)userID {
    
    if (session == self.session) {
        // remove user from the collection
        [self removeFromCollectionUserWithID:userID];
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = state;
        }];
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        __weak __typeof(self)weakSelf = self;
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            QBRTCRemoteVideoView *opponentVideoView = (id)[weakSelf videoViewWithOpponentID:userID];
            [cell setVideoView:opponentVideoView];
        }];
    }
}

// MARK: QBRTCConferenceClientDelegate

- (void)didCreateNewSession:(QBRTCConferenceSession *)session {
    
    if (session == self.session) {
        
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
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
        
        session.localMediaStream.audioTrack.enabled = !self.muteAudio;
        session.localMediaStream.videoTrack.enabled = !self.muteVideo;
        
        if (self.cameraCapture != nil) {
            session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
        }
        
        if (_conferenceType > 0) {
            [session joinAsPublisher];
        }
        else {
            self.state = CallViewControllerStateConnected;
            __weak __typeof(self)weakSelf = self;
            [self.session listOnlineParticipantsWithCompletionBlock:^(NSArray<NSNumber *> * _Nonnull publishers, NSArray<NSNumber *> * _Nonnull listeners) {
                for (NSNumber *userID in publishers) {
                    [weakSelf.session subscribeToUserWithID:userID];
                }
            }];
        }
    }
}

- (void)session:(QBRTCConferenceSession *)session didJoinChatDialogWithID:(NSString *)chatDialogID publishersList:(NSArray *)publishersList {
    
    if (session == self.session) {
        
        self.state = CallViewControllerStateConnected;
        for (NSNumber *userID in publishersList) {
            [self.session subscribeToUserWithID:userID];
            [self addToCollectionUserWithID:userID];
        }
    }
}

- (void)session:(QBRTCConferenceSession *)session didReceiveNewPublisherWithUserID:(NSNumber *)userID {
    
    if (session == self.session) {
        
        // subscribing to user to receive his media
        [self.session subscribeToUserWithID:userID];
    }
}

- (void)session:(QBRTCConferenceSession *)session publisherDidLeaveWithUserID:(NSNumber *)userID {
    
    if (session == self.session) {
        
        // in case we are zoomed into leaving publisher
        // cleaning it here
        if ([_statsUserID isEqualToNumber:userID]) {
            [self unzoomVideoView];
        }
    }
}

- (void)sessionWillClose:(QBRTCConferenceSession *)session {
    
    if (session == self.session) {
        
        if ([QBRTCAudioSession instance].isInitialized) {
            // deinitializing audio session if needed
            [[QBRTCAudioSession instance] deinitialize];
        }
        
        [self closeCallWithTimeout:NO];
    }
}

- (void)sessionDidClose:(QBRTCConferenceSession *)session withTimeout:(BOOL)timeout {
    
    if (session == self.session
        && self.state != CallViewControllerStateDisconnected) {
        
        [self closeCallWithTimeout:timeout];
    }
}

- (void)session:(QBRTCConferenceSession *)session didReceiveError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

// MARK: QBRTCAudioSessionDelegate

- (void)audioSession:(QBRTCAudioSession *)audioSession didChangeCurrentAudioDevice:(QBRTCAudioDevice)updatedAudioDevice {
    
    if (!_didStartPlayAndRecord) {
        return;
    }
    
    BOOL isSpeaker = updatedAudioDevice == QBRTCAudioDeviceSpeaker;
    if (self.dynamicEnable.pressed != isSpeaker) {
        
        self.dynamicEnable.pressed = isSpeaker;
    }
}

- (void)audioSessionDidStartPlayOrRecord:(QBRTCAudioSession *)audioSession {
    _didStartPlayAndRecord = YES;
    audioSession.currentAudioDevice = QBRTCAudioDeviceSpeaker;
}

- (void)audioSessionDidStopPlayOrRecord:(QBRTCAudioSession *)audioSession {
    _didStartPlayAndRecord = NO;
}

// MARK: Overrides

- (void)setState:(CallViewControllerState)state {
    
    if (_state != state) {
        switch (state) {
            case CallViewControllerStateDisconnected:
                self.title = @"Disconnected";
                break;
                
            case CallViewControllerStateConnecting:
                self.title = @"Connecting...";
                break;
                
            case CallViewControllerStateConnected:
                self.title = @"Connected";
                break;
                
            case CallViewControllerStateDisconnecting:
                self.title = @"Disconnecting...";
                break;
        }
        
        _state = state;
    }
}

- (void)setMuteAudio:(BOOL)muteAudio {
    
    if (_muteAudio != muteAudio) {
        _muteAudio = muteAudio;
        self.session.localMediaStream.audioTrack.enabled = !muteAudio;
    }
}

- (void)setMuteVideo:(BOOL)muteVideo {
    
    if (_muteVideo != muteVideo) {
        _muteVideo = muteVideo;
        self.session.localMediaStream.videoTrack.enabled = !muteVideo;
    }
}

// MARK: Actions

- (void)pushAddUsersToRoomScreen {
    [self performSegueWithIdentifier:kUsersSegue sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self.cameraCapture stopSession:nil];
    if ([segue.identifier isEqualToString:kUsersSegue]) {
        
        AddUsersViewController *usersVC = (id)segue.destinationViewController;
        usersVC.usersDataSource = self.usersDataSource;
        usersVC.chatDialog = self.chatDialog;
    }
}

- (void)zoomVideoView:(UIView *)videoView {
    [_zoomedView setVideoView:videoView];
    _zoomedView.hidden = NO;
    self.navigationItem.rightBarButtonItem = self.statsItem;
}

- (void)unzoomVideoView {
    if (self.originCell != nil) {
        self.originCell.videoView = _zoomedView.videoView;
        _zoomedView.videoView = nil;
        self.originCell = nil;
        _zoomedView.hidden = YES;
        _statsUserID = nil;
        self.navigationItem.rightBarButtonItem = self.addUsersItem;
    }
}

- (void)addToCollectionUserWithID:(NSNumber *)userID {
    
    QBUUser *user = [self userWithID:userID];
    if ([self.users indexOfObject:user] != NSNotFound) {
        return;
    }
    [self.users insertObject:user atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    __weak __typeof(self)weakSelf = self;
    [self.opponentsCollectionView performBatchUpdates:^{
        
        [weakSelf.opponentsCollectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
        [weakSelf refreshVideoViews];
    }];
    
}

- (void)removeFromCollectionUserWithID:(NSNumber *)userID {
    
    QBUUser *user = [self userWithID:userID];
    NSInteger index = [self.users indexOfObject:user];
    if (index == NSNotFound) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.users removeObject:user];
    [self.videoViews removeObjectForKey:userID];
    
    __weak __typeof(self)weakSelf = self;
    [self.opponentsCollectionView performBatchUpdates:^{
        
        [weakSelf.opponentsCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
        [weakSelf refreshVideoViews];
    }];
}

- (void)closeCallWithTimeout:(BOOL)timeout {
    
    // removing delegate on close call so we don't get any callbacks
    // that will force collection view to perform updates
    // while controller is deallocating
    [[QBRTCConferenceClient instance] removeDelegate:self];
    
    // stopping camera session
    [self.cameraCapture stopSession:nil];
    
    // toolbar
    self.toolbar.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.toolbar.alpha = 0.4;
    }];
    
    self.state = CallViewControllerStateDisconnected;
    
    if (timeout) {
        [SVProgressHUD showErrorWithStatus:@"Conference did close due to time out"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        // dismissing progress hud if needed
        [self.navigationController popToRootViewControllerAnimated:YES];
        [SVProgressHUD dismiss];
    }
}

- (void)leaveFromRoom {
    self.state = CallViewControllerStateDisconnecting;
    if (self.session.state == QBRTCSessionStatePending) {
        [self closeCallWithTimeout:NO];
    }
    else if (self.session.state != QBRTCSessionStateNew) {
        [SVProgressHUD showWithStatus:nil];
    }
    [self.session leave];
}

- (void)refreshVideoViews {
    
    // resetting zoomed view
    UIView *zoomedVideoView = self.zoomedView.videoView;
    for (OpponentCollectionViewCell *viewToRefresh  in self.opponentsCollectionView.visibleCells) {
        UIView *view = viewToRefresh.videoView;
        if (view == zoomedVideoView) {
            continue;
        }
        
        [viewToRefresh setVideoView:nil];
        [viewToRefresh setVideoView:view];
    }
}

- (void)updateStatsView {
    self.shouldGetStats ^= 1;
    self.statsView.hidden ^= 1;
}

// MARK: Helpers

static inline __kindof UIView *prepareSubview(UIView *view, Class subviewClass) {
    
    UIView *subview = [[subviewClass alloc] initWithFrame:view.bounds];
    subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    subview.hidden = YES;
    [view addSubview:subview];
    return subview;
}

- (UIView *)videoViewWithOpponentID:(NSNumber *)opponentID {
    
    if (!self.videoViews) {
        self.videoViews = [NSMutableDictionary dictionary];
    }
    
    id result = self.videoViews[opponentID];
    
    if (Core.currentUser.ID == opponentID.integerValue
        && self.session.conferenceType != QBRTCConferenceTypeAudio) {//Local preview
        
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
            [remoteVideoView setVideoTrack:remoteVideoTraсk];
            result = remoteVideoView;
        }
        
        return result;
    }
    
    return result;
}

- (QBUUser *)userWithID:(NSNumber *)userID {
    
    QBUUser *user = [self.usersDataSource userWithID:userID.unsignedIntegerValue];
    
    if (!user) {
        user = [QBUUser user];
        user.ID = userID.unsignedIntegerValue;
    }
    
    return user;
}

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {
    
    QBUUser *user = [self userWithID:userID];
    NSUInteger idx = [self.users indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

- (void)performUpdateUserID:(NSNumber *)userID block:(void(^)(OpponentCollectionViewCell *cell))block {
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    OpponentCollectionViewCell *cell = (id)[self.opponentsCollectionView cellForItemAtIndexPath:indexPath];
    block(cell);
}

// MARK: LocalVideoViewDelegate

- (void)localVideoView:(LocalVideoView *)localVideoView pressedSwitchButton:(UIButton *)sender {
    
    AVCaptureDevicePosition position = self.cameraCapture.position;
    AVCaptureDevicePosition newPosition = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    if ([self.cameraCapture hasCameraForPosition:newPosition]) {
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.75f;
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
