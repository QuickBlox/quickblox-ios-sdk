//
//  BaseCallViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 22.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "BaseCallViewController.h"
#import "Settings.h"
#import "UIColor+Chat.h"
#import "OpponentsFlowLayout.h"
#import "BaseSettingsCell.h"
#import "SharingViewController.h"
#import "UIViewController+Alert.h"
#import "Profile.h"


static NSString * const kConferenceUserCellIdentifier = @"ConferenceUserCell";

@interface BaseCallViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCAudioSessionDelegate, QBRTCConferenceClientDelegate>

@property (strong, nonatomic) CustomButton *videoEnabled;
@property (strong, nonatomic) CustomButton *screenShareEnabled;
@property (strong, nonatomic) NSNumber *selectedUserID;
@property (nonatomic, strong) CompletionActionBlock closeCallActionCompletion;
@property (assign, nonatomic) QBRTCConferenceType conferenceType;
@property (assign, nonatomic) BOOL didStartPlayAndRecord;

@end

@implementation BaseCallViewController

// MARK: Life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (instancetype)initWithConferenceSettings:(ConferenceSettings *)conferenceSettings {
    self = [super init];
    if (self) {
        self.conferenceSettings = conferenceSettings;
        self.chatManager = [ChatManager instance];
        [self setupDelegates];
        self.participants = [[CallParticipants alloc] init];
    }
    return self;
}

- (void)setMuteAudio:(BOOL)muteAudio {
    _muteAudio = muteAudio;
    self.session.localMediaStream.audioTrack.enabled = !muteAudio;
}

- (void)setMuteVideo:(BOOL)muteVideo {
    _muteVideo = muteVideo;
    [self didSetMuteVideo:muteVideo];
}

- (void)didSetMuteVideo:(BOOL)muteVideo {
    self.session.localMediaStream.videoTrack.enabled = !muteVideo;
    self.swapCamera.userInteractionEnabled = self.session.localMediaStream.videoTrack.enabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureGUI];
    [self setupSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupLocalMediaStreamVideoCapture];
    self.session.localMediaStream.videoTrack.enabled = !self.muteVideo;
    [self setupNavigationBarWillAppear:YES];
    self.screenShareEnabled.pressed = NO;
    [self showControls:YES];
    [self setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setupNavigationBarWillAppear:NO];
    [self invalidateHideToolbarTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [SVProgressHUD showWithStatus:@"MEMORY WARNING: leaving out of call"];
    [self leaveFromRoomWithAnimated:NO completion:nil];
}

- (void)setupLocalMediaStreamVideoCapture {
    self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
}

- (void)cameraCaptureStopSession {
    self.session.localMediaStream.videoTrack.enabled = NO;
}

- (void)setupDelegates {
    [[QBRTCConferenceClient instance] addDelegate:self];
    [[QBRTCAudioSession instance] addDelegate:self];
}

- (void)didTapChat:(UIBarButtonItem *)sender {
    self.session.localMediaStream.videoTrack.enabled = NO;
    if (self.didClosedCallScreen) {
        self.didClosedCallScreen(NO);
    }
}

- (void)configureToolBar {
    __weak __typeof(self)weakSelf = self;
    
    [self.toolbar addButton:[ButtonsFactory auidoEnable] action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.muteAudio = !strongSelf.muteAudio;
        [strongSelf setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
    }];
    self.muteVideo = YES;
    
    
    self.videoEnabled = [ButtonsFactory videoEnable];
    [self.toolbar addButton:self.videoEnabled action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf cameraTurnOn:strongSelf.muteVideo];
        [strongSelf setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
    }];
    self.videoEnabled.pressed = YES;
    

    [self.toolbar addButton:[ButtonsFactory decline] action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
        [strongSelf leaveFromRoomWithAnimated:YES completion:nil];
    }];
    
    
    self.screenShareEnabled = [ButtonsFactory screenShare];
    [self.toolbar addButton:self.screenShareEnabled action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        
        SharingViewController *sharingVC = [[SharingViewController alloc] init];
        [sharingVC setDidSetupSharingScreenCapture:^(SharingScreenCapture * _Nonnull screenCapture) {
            if (screenCapture && strongSelf.session.localMediaStream.videoTrack.videoCapture != screenCapture) {
                strongSelf.session.localMediaStream.videoTrack.videoCapture = screenCapture;
            }
            strongSelf.session.localMediaStream.videoTrack.enabled = YES;
        }];
        
        [sharingVC setDidCloseSharingVC:^{
            strongSelf.session.localMediaStream.videoTrack.videoCapture = strongSelf.cameraCapture;
            strongSelf.session.localMediaStream.videoTrack.enabled = !strongSelf.muteVideo;
            [strongSelf cameraTurnOn:!strongSelf.muteVideo];
        }];

        [strongSelf presentViewController:sharingVC animated:NO completion:^{
            strongSelf.screenShareEnabled.pressed = NO;
        }];
        
    }];
    
    self.swapCamera = [ButtonsFactory swapCam];
    self.swapCamera.userInteractionEnabled = NO;
    [self.toolbar addButton:self.swapCamera action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.muteVideo) {
            return;
        }
        if ([strongSelf.participants videoViewWithId:strongSelf.participants.localId] == nil) {
            return;
        }
        LocalVideoView *localVideoView = (LocalVideoView *)[weakSelf.participants videoViewWithId:weakSelf.participants.localId];
        [strongSelf setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
        
        AVCaptureDevicePosition position = strongSelf.cameraCapture.position;
        AVCaptureDevicePosition newPosition = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        
        if ([strongSelf.cameraCapture hasCameraForPosition:newPosition]) {
            
            CATransition *animation = [CATransition animation];
            animation.duration = 0.75f;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = @"oglFlip";
            
            if (position == AVCaptureDevicePositionFront) {
                animation.subtype = kCATransitionFromRight;
            } else if(position == AVCaptureDevicePositionBack) {
                animation.subtype = kCATransitionFromLeft;
            }
            
            [localVideoView.superview.layer addAnimation:animation forKey:nil];
            strongSelf.cameraCapture.position = newPosition;
        }
    }];
    
    [self.toolbar updateItems];
}

- (void)reloadContent {
    for (CallParticipant *participant in self.participants.participants) {
        UIView *videoView = [self.participants videoViewWithId:participant.ID];
        [videoView removeFromSuperview];
    }
    [self.collectionView reloadData];
}

- (void)leaveFromRoomWithAnimated:(BOOL)animated completion:(CompletionActionBlock _Nullable)completion {
    if (completion) {
        self.closeCallActionCompletion = completion;
    }
    if (self.session.state == QBRTCSessionStatePending) {
        [self closeCallWithTimeout:NO];
    } else if (self.session.state != QBRTCSessionStateNew) {
        [SVProgressHUD showWithStatus:nil];
    }
    [SVProgressHUD dismiss];
    [self.session leave];
}

- (void)zoomUser:(NSNumber *)userID {
    self.selectedUserID = userID;
    [self reloadContent];
}

- (void)unzoomUser {
    self.selectedUserID = nil;
    [self reloadContent];
}

- (void)updateWithCreatedNewSession:(QBRTCConferenceSession *)session {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    
    QBRTCAudioSessionConfiguration *configuration = [[QBRTCAudioSessionConfiguration alloc] init];
    configuration.categoryOptions |= AVAudioSessionCategoryOptionDuckOthers;
    
    // adding blutetooth support
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    
    // adding airplay support
    configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
    
    configuration.mode = AVAudioSessionModeVideoChat;
    
    [audioSession setConfiguration:configuration active:YES];

    if (!self.cameraCapture) {
        Settings *settings = [[Settings alloc] init];
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPostion];
    }
    self.session.localMediaStream.audioTrack.enabled = YES;
    self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
    self.session.localMediaStream.videoTrack.enabled = NO;
    [self.session joinAsPublisher];
}

- (void)addNewPublisher:(QBUUser *)user {
    [self.participants addParticipantWithId:@(user.ID) fullName:user.fullName];
    [self reloadContent];
}

- (void)closeCallWithTimeout:(BOOL)timeout {
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    NSArray *controllers = self.navigationController.viewControllers;
    NSMutableArray *newStack = [NSMutableArray array];
    
    //change stack by replacing view controllers after CallViewController
    for (UIViewController *controller in controllers) {
        [newStack addObject:controller];
        
        if ([controller isKindOfClass:[BaseCallViewController class]]) {
            [self.navigationController setViewControllers:[newStack copy]];
            break;
        }
    }
    
    // removing delegate on close call so we don't get any callbacks
    // that will force collection view to perform updates
    // while controller is deallocating
    [[QBRTCConferenceClient instance] removeDelegate:self];
    
    // stopping camera session
    [self.cameraCapture stopSession:nil];
    
    [self invalidateHideToolbarTimer];
    
    // toolbar
    self.toolbar.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.toolbar.alpha = 0.3;
    }];
    // dismissing progress hud if needed
    [SVProgressHUD dismiss];
    
    self.session = nil;
    
    if (self.closeCallActionCompletion) {
        self.closeCallActionCompletion();
        self.closeCallActionCompletion = nil;
    } else if (self.didClosedCallScreen) {
        self.didClosedCallScreen(YES);
    }
}

- (void)cameraTurnOn:(BOOL)turnOn {
    // localMediaStream videoTrack set to Enable/disable
    // stop/start cammera session
    // update user states updateUserStates
    // send trakcs States
    
#if TARGET_OS_SIMULATOR
    // Simulator
#else
    //Device
    if (turnOn == YES) {
        if (!self.cameraCapture.isRunning) {
            [self.cameraCapture startSession:nil];
        }
        if ([self.participants videoViewWithId:self.participants.localId] == nil) {
            Settings *settings = [[Settings alloc] init];
            self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                        position:settings.preferredCameraPostion];
            
            LocalVideoView *localVideoView = [[LocalVideoView alloc] initWithPreviewlayer:self.cameraCapture.previewLayer];
            [self.participants addVideView:localVideoView withId:self.participants.localId];
            [self setupLocalMediaStreamVideoCapture];
            [self reloadContent];
        }
    }
    
    [self.participants participantWithId:self.participants.localId].isCameraEnabled = turnOn;
    self.muteVideo = !turnOn;
    [self.participants videoViewWithId:self.participants.localId].hidden = !turnOn;
#endif
}

- (void)addToCollectionUserWithID:(NSNumber *)userID {
    CallParticipant *participant = [self.participants participantWithId:userID];
    if (participant) {
        return;
    }
    QBUUser *user = [self.chatManager.storage userWithID:userID.unsignedIntValue];
    if (!user) {
        [self.chatManager loadUserWithID:userID.unsignedIntValue completion:^(QBUUser * _Nullable loadedUser) {
            [self addNewPublisher:loadedUser];
        }];
    }
    [self addNewPublisher:user];
}

- (void)removeUserFromCollection:(NSNumber *)userID {
    [self.participants removeParticipantWithId:userID];
}

- (UIView *)userViewWithUserID:(NSNumber *)userID {

    id result = [self.participants videoViewWithId:userID];
    Profile *profile = [[Profile alloc] init];
    if (profile.ID == userID.unsignedIntValue) {
        if (!result) {
            if (!self.cameraCapture) {
                Settings *settings = [[Settings alloc] init];
                self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                            position:settings.preferredCameraPostion];
            }
            LocalVideoView *localVideoView = [[LocalVideoView alloc] initWithPreviewlayer:self.cameraCapture.previewLayer];
            [self.participants addVideView:localVideoView withId:userID];
            
            return localVideoView;
        }
    }
    else {//Opponents

        QBRTCRemoteVideoView *remoteVideoView = nil;
        QBRTCVideoTrack *remoteVideoTraсk = [self.session remoteVideoTrackWithUserID:userID];
        if (result) {
            remoteVideoView = (QBRTCRemoteVideoView *)[self.participants videoViewWithId:userID];
        } else if (!result && remoteVideoTraсk) {
            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2, 2, 2, 2)];
        }
        remoteVideoView.videoGravity = AVLayerVideoGravityResizeAspect;
        [remoteVideoView setVideoTrack:remoteVideoTraсk];
        [self.participants addVideView:remoteVideoView withId:userID];
        return remoteVideoView;
    }

    return result;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout= [[OpponentsFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    UINib *nibConferenceCell = [UINib nibWithNibName:kConferenceUserCellIdentifier bundle:nil];
    [self.collectionView registerNib:nibConferenceCell forCellWithReuseIdentifier:kConferenceUserCellIdentifier];
}

- (void)setupSession {
    if (!QBSession.currentSession.currentUser) {
        return;
    }
    QBUUser *currentUser = QBSession.currentSession.currentUser;

    // creating session
    NSString *conferenceID = self.conferenceSettings.conferenceInfo.conferenceID;
    self.session = [[QBRTCConferenceClient instance] createSessionWithChatDialogID:conferenceID conferenceType:QBRTCConferenceTypeVideo];
    if (!self.session) {
        return;
    }
    [self.participants addParticipantWithId:@(currentUser.ID) fullName:currentUser.name];
}

- (void)setupAudioVideoEnabledCell:(ConferenceUserCell *)cell forUserID:(NSNumber *)userID {
    // configure it if necessary. for example see ConferenceViewController
}

// MARK: QBRTCAudioSessionDelegate
- (void)audioSession:(QBRTCAudioSession *)audioSession didChangeCurrentAudioDevice:(QBRTCAudioDevice)updatedAudioDevice {
    if (!self.didStartPlayAndRecord) {
        return;
    }
}

- (void)audioSessionDidStartPlayOrRecord:(QBRTCAudioSession *)audioSession {
    self.didStartPlayAndRecord = YES;
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
}

- (void)audioSessionDidStopPlayOrRecord:(QBRTCAudioSession *)audioSession {
    self.didStartPlayAndRecord = NO;
}

// MARK: QBRTCConferenceClientDelegate
- (void)didCreateNewSession:(QBRTCConferenceSession *)session {
    if (session != self.session) {
        return;
    }
    
    if (self.conferenceSettings.isSendMessage) {
        [self.chatManager sendStartConferenceMessage:self.conferenceSettings.conferenceInfo completion:^(NSError * _Nullable error) {
            if (error) {
                Log(@"[%@] sendStartConferenceMessage error: %@",
                    NSStringFromClass([ChatStorage class]),
                    error.localizedDescription);
            }
        }];
    }
    
    // updated UI with Created New Session
    [self updateWithCreatedNewSession:session];
}

- (void)session:(QBRTCConferenceSession *)session didJoinChatDialogWithID:(NSString *)chatDialogID publishersList:(NSArray *)publishersList {
    if (session != self.session) {
        return;
    }
    for (NSNumber *userID in publishersList) {
        [self.session subscribeToUserWithID:userID];
        [self addToCollectionUserWithID:userID];
    }
}

- (void)session:(QBRTCConferenceSession *)session didReceiveNewPublisherWithUserID:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    [self.session subscribeToUserWithID:userID];
    [self addToCollectionUserWithID:userID];
}

- (void)session:(QBRTCConferenceSession *)session publisherDidLeaveWithUserID:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    // in case we are zoomed into leaving publisher
    // cleaning it here
    if (self.selectedUserID && self.selectedUserID == userID) {
        self.selectedUserID = nil;
    }
    [self reloadContent];
}

- (void)sessionWillClose:(QBRTCConferenceSession *)session {
    if (session != self.session) {
        return;
    }
    if (QBRTCAudioSession.instance.isActive) {
        [QBRTCAudioSession.instance setActive:NO];
    }
    [self closeCallWithTimeout:NO];
}

- (void)sessionDidClose:(QBRTCConferenceSession *)session withTimeout:(BOOL)timeout {
    if (session != self.session) {
        return;
    }
    [self closeCallWithTimeout:NO];
}

- (void)session:(QBRTCConferenceSession *)session didReceiveError:(NSError *)error {
    [self cancelCallAlertWithTitle:error.localizedDescription message:nil];
}

// MARK: Helpers
- (void)cancelCallAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self closeCallWithTimeout:NO];
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

// MARK: QBRTCBaseClientDelegate
- (void)session:(__kindof QBRTCBaseSession *)session startedConnectingToUser:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
}

- (void)session:(__kindof QBRTCBaseSession *)session connectionClosedForUser:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    id videoView = [self.participants videoViewWithId:userID];
    if (videoView) {
        [videoView removeFromSuperview];
    }

    // remove user from the collection
    [self removeUserFromCollection:userID];
    [self reloadContent];
}

- (void)session:(__kindof QBRTCBaseSession *)session didChangeConnectionState:(QBRTCConnectionState)state forUser:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    CallParticipant *user = [self.participants participantWithId:userID];
    user.connectionState = state;
}

- (void)session:(__kindof QBRTCBaseSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    [self reloadContent];
}

// MARK: UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.selectedUserID) {
        return 1;
    }
    return self.participants.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ConferenceUserCell *cell = [collectionView
                                dequeueReusableCellWithReuseIdentifier:kConferenceUserCellIdentifier
                                forIndexPath:indexPath];
    
    NSUInteger index = self.selectedUserID ? [self.participants participantIndexWithId:self.selectedUserID] : indexPath.item;

    CallParticipant *user = [self.participants participantWithIndex:index];
    cell.videoView = [self userViewWithUserID:user.ID];
    cell.videoEnabled = YES;
    
    // label for user
    cell.name = user.fullName;
    cell.nameColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                  (unsigned long)user.ID.unsignedIntValue]];
    // configure it if necessary. for example see ConferenceViewController
    [self setupAudioVideoEnabledCell:cell forUserID:user.ID];
    
    if (self.participants.localId == user.ID) {
        return cell;
    }

    __block QBRTCRemoteVideoView *videoView = (QBRTCRemoteVideoView *)cell.videoView;
    [cell setDidChangeVideoGravity:^(BOOL isResizeAspect) {
        if (isResizeAspect) {
            [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                videoView.videoGravity = AVLayerVideoGravityResizeAspect;
            } completion:nil];
        } else {
            [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                videoView.videoGravity = AVLayerVideoGravityResizeAspectFill;
            } completion:nil];
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showControls:YES];
    
    CallParticipant *user = [self.participants participantWithIndex:indexPath.item];
    if (user.ID == self.participants.localId) {
        // do not zoom local video view
        return;
    }
    self.selectedUserID == nil ? [self zoomUser:user.ID] : [self unzoomUser];
}

@end
