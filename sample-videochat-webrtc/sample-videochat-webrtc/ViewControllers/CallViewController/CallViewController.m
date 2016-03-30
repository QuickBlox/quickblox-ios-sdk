//
//  CallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CallViewController.h"
#import "ChatManager.h"
#import "CornerView.h"
#import "LocalVideoView.h"
#import "OpponentCollectionViewCell.h"
#import "OpponentsFlowLayout.h"
#import "QBButton.h"
#import "QBButtonsFactory.h"
#import "QBToolBar.h"
#import "QMSoundManager.h"
#import "SampleCore.h"
#import "Settings.h"
#import "SharingViewController.h"
#import "UsersDataSourceProtocol.h"
#import <mach/mach.h>

NSString *const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";
NSString *const kSharingViewControllerIdentifier = @"SharingViewController";

const NSTimeInterval kRefreshTimeInterval = 1.f;

@interface QBRTCRemoteVideoView (VideoGravity)

@property (nonatomic, strong, readonly) QBRTCRemoteVideoView *renderer;

@end

@interface CallViewController ()

<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCClientDelegate, LocalVideoViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet QBToolBar *toolbar;

@property (assign, nonatomic) NSTimeInterval timeDuration;

@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;

@property (strong, nonatomic) NSMutableDictionary *videoViews;

@property (assign, nonatomic, readonly) BOOL isOffer;

@property (strong, nonatomic) UIView *zoomedView;
@property (strong, nonatomic) OpponentCollectionViewCell *zoomedViewOpponentCell;

@property (strong, nonatomic) QBButton *videoEnabled;
@property (weak, nonatomic) LocalVideoView *localVideoView;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation CallViewController

- (void)dealloc {
    
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[QBRTCClient instance] addDelegate:self];
    
    [self configureUsers];
    [self configureOpponentEnlargingByDoubleTap];
    [self configureGUI];
    [self configureSoundRouter];
    [self configureCameraCapture];
    [self start];
}

- (void)start {
    
    [SampleCore chatManager].hasActiveCall = YES;
    
    self.title = @"Connecting...";
    
    if (self.isOffer) {
        
        [self startCall];
    }
    else {
        
        [self acceptCall];
    }
}

- (void)configureCameraCapture {
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        Settings *settings = [SampleCore settings];
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPosition];
        [self.cameraCapture startSession];
    }
}

- (void)configureUsers {
    
    QBUUser *initiator = [[SampleCore usersDataSource] userWithID:self.session.initiatorID];
    _isOffer = [[SampleCore usersDataSource].currentUser isEqual:initiator];
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:self.session.opponentsIDs.count + 1];
    [users insertObject:[SampleCore usersDataSource].currentUser atIndex:0];
    
    NSMutableArray *opponents = [[SampleCore usersDataSource] usersWithIDSWithoutMe:self.session.opponentsIDs].mutableCopy;
    
    if (!self.isOffer) {
        
        [opponents addObject:initiator];
    }
    
    [users addObjectsFromArray:opponents];
    
    self.users = users.copy;
}

- (void)configureSoundRouter {
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        [QBRTCSoundRouter instance].currentSoundRoute = QBRTCSoundRouteReceiver;
    }
}

- (UIView *)videoViewWithOpponentID:(NSNumber *)opponentID {
    
    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        return nil;
    }
    
    if (!self.videoViews) {
        self.videoViews = [NSMutableDictionary dictionary];
    }
    
    id opponentVideoView = self.videoViews[opponentID];
    
    if ([SampleCore usersDataSource].currentUser.ID == opponentID.integerValue) {
        //Local preview
        
        if (!opponentVideoView) {
            
            LocalVideoView *localVideoView = [[LocalVideoView alloc] initWithPreviewLayer:self.cameraCapture.previewLayer];
            self.videoViews[opponentID] = localVideoView;
            localVideoView.delegate = self;
            self.localVideoView = localVideoView;
            return localVideoView;
        }
    }
    else {
        //Opponents
        
        QBRTCRemoteVideoView *remoteVideoView = nil;
        QBRTCVideoTrack *remoteVideoTrack = [self.session remoteVideoTrackWithUserID:opponentID];
        
        if (!opponentVideoView && remoteVideoTrack) {
            
            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:self.view.bounds];
            
            self.videoViews[opponentID] = remoteVideoView;
            opponentVideoView = remoteVideoView;
        }
        
        [remoteVideoView setVideoTrack:remoteVideoTrack];
        
        return opponentVideoView;
    }
    
    return opponentVideoView;
}

- (void)sendPushToOpponentAboutNewCall {
    
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"%@ is calling you", [SampleCore usersDataSource].currentUser.fullName]
                        toUsers:[self.session.opponentsIDs componentsJoinedByString:@","]
                   successBlock:nil
                     errorBlock:^(QBError * _Nullable error)
     {
         NSLog(@"Can not send push: %@", error);
     }];
}

#pragma mark - Start / Accept call

- (void)startCall {
    //Begin play calling sound
    [self sendPushToOpponentAboutNewCall];
    //Start call
    NSDictionary *userInfo = @{@"startCall" : @"userInfo"};
    [self.session startCall:userInfo];
    
}

- (void)acceptCall {
    
    [QMSysPlayer stopAllSounds];
    //Accept call
    NSDictionary *userInfo = @{@"acceptCall" : @"userInfo"};
    [self.session acceptCall:userInfo];
}

- (void)configureGUI {
    
    self.view.backgroundColor =
    self.opponentsCollectionView.backgroundColor =
    [UIColor colorWithRed:0.1465 green:0.1465 blue:0.1465 alpha:1.0];
    
    __weak __typeof(self)weakSelf = self;
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        self.videoEnabled = [QBButtonsFactory videoEnable];
        [self.toolbar addButton:self.videoEnabled action: ^(UIButton *sender) {
            
            weakSelf.session.localMediaStream.videoTrack.enabled ^=1;
            weakSelf.localVideoView.hidden = !weakSelf.session.localMediaStream.videoTrack.enabled;
        }];
    }
    
    [self.toolbar addButton:[QBButtonsFactory audioEnable] action: ^(UIButton *sender) {
        
        weakSelf.session.localMediaStream.audioTrack.enabled ^=1;
    }];
    
    [self.toolbar addButton:[QBButtonsFactory speakerEnable] action:^(UIButton *sender) {
        
        QBRTCSoundRoute route = [QBRTCSoundRouter instance].currentSoundRoute;
        
        [QBRTCSoundRouter instance].currentSoundRoute =
        route == QBRTCSoundRouteSpeaker ? QBRTCSoundRouteReceiver : QBRTCSoundRouteSpeaker;
    }];
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
        [self.toolbar addButton:[QBButtonsFactory screenShare] action: ^(UIButton *sender) {
            
            SharingViewController *sharingVC =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:kSharingViewControllerIdentifier];
            sharingVC.session = weakSelf.session;
            
            [weakSelf.navigationController pushViewController:sharingVC animated:YES];
        }];
    }
    
    [self.toolbar addButton:[QBButtonsFactory decline] action: ^(UIButton *sender) {
        
        [weakSelf.session hangUp:@{@"hangup" : @"hang up"}];
    }];
    
    [self.toolbar updateItems];
}

#pragma mark Double tap — enlarge opponent view

- (void)configureOpponentEnlargingByDoubleTap {
    
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(didDoubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.navigationController.view addGestureRecognizer:self.doubleTapGestureRecognizer];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint point = [gesture locationInView:self.opponentsCollectionView];
        NSIndexPath *indexPath = [self.opponentsCollectionView indexPathForItemAtPoint:point];
        
        if (!indexPath) {
            return;
        }
        
        OpponentCollectionViewCell *tappedCell = (id)[self.opponentsCollectionView cellForItemAtIndexPath:indexPath];
        
        if (!self.zoomedView) {
            
            [self setZoomedViewWithCollectionViewCell:tappedCell];
        }
        else {
            
            [self removeZoomedView];
        }
    }
}

- (void)setZoomedViewWithCollectionViewCell:(OpponentCollectionViewCell *)opponentViewCell {
    
    NSParameterAssert(!self.zoomedView);
    NSParameterAssert(!self.zoomedViewOpponentCell);
    NSParameterAssert(opponentViewCell);
    
    self.zoomedViewOpponentCell = opponentViewCell;
    self.zoomedView = self.zoomedViewOpponentCell.videoView;
    self.zoomedViewOpponentCell.videoView = nil;
    self.zoomedView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.zoomedView.backgroundColor = [UIColor blackColor];
    self.zoomedView.frame = self.navigationController.view.bounds;
    
    [self.navigationController.view addSubview:self.zoomedView];
}

- (void)removeZoomedView {
    
    NSParameterAssert(self.zoomedView);
    
    [self.zoomedView removeFromSuperview];
    
    self.zoomedViewOpponentCell.videoView = self.zoomedView;
    self.zoomedView = nil;
    self.zoomedViewOpponentCell = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OpponentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier forIndexPath:indexPath];
    QBUUser *user = self.users[indexPath.row];
    UIColor *userColor = [[SampleCore usersDataSource] colorAtUser:user];
    
    [cell setVideoView:[self videoViewWithOpponentID:@(user.ID)]];
    [cell setMarkerText:[user.fullName substringToIndex:1]];
    [cell setMarkerColor:userColor];
    
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (!self.zoomedView) {
        [self.opponentsCollectionView performBatchUpdates:nil completion:nil];// Calling -performBatchUpdates:completion: will invalidate the layout and resize the cells with animation
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect frame = [OpponentsFlowLayout frameForWithNumberOfItems:self.users.count
                                                              row:indexPath.row
                                                      contentSize:self.opponentsCollectionView.frame.size];
    return frame.size;
}

#pragma mark - Transition to size

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {
    
    QBUUser *user = [[SampleCore usersDataSource] userWithID:userID];
    NSUInteger idx = [self.users indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

- (OpponentCollectionViewCell *)performUpdateUserID:(NSNumber *)userID {
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    OpponentCollectionViewCell *cell = (id)[self.opponentsCollectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

#pragma Statistics

NSInteger QBRTCGetCpuUsagePercentage() {
    // Create an array of thread ports for the current task.
    const task_t task = mach_task_self();
    thread_act_array_t thread_array;
    mach_msg_type_number_t thread_count;
    if (task_threads(task, &thread_array, &thread_count) != KERN_SUCCESS) {
        return -1;
    }
    
    // Sum cpu usage from all threads.
    float cpu_usage_percentage = 0;
    thread_basic_info_data_t thread_info_data = {};
    mach_msg_type_number_t thread_info_count;
    for (size_t i = 0; i < thread_count; ++i) {
        thread_info_count = THREAD_BASIC_INFO_COUNT;
        kern_return_t ret = thread_info(thread_array[i],
                                        THREAD_BASIC_INFO,
                                        (thread_info_t)&thread_info_data,
                                        &thread_info_count);
        if (ret == KERN_SUCCESS) {
            cpu_usage_percentage +=
            100.f * (float)thread_info_data.cpu_usage / TH_USAGE_SCALE;
        }
    }
    
    // Dealloc the created array.
    vm_deallocate(task, (vm_address_t)thread_array,
                  sizeof(thread_act_t) * thread_count);
    
    return lroundf(cpu_usage_percentage);
}

#pragma mark - QBRTCClientDelegate

- (void)session:(QBRTCSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
    
    NSMutableString *result = [NSMutableString string];
    NSString *systemStatsFormat = @"(cpu)%ld%%\n";
    [result appendString:[NSString stringWithFormat:systemStatsFormat,
                          (long)QBRTCGetCpuUsagePercentage()]];
    
    // Connection stats.
    NSString *connStatsFormat = @"CN %@ms | %@->%@/%@ | (s)%@ | (r)%@\n";
    [result appendString:[NSString stringWithFormat:connStatsFormat,
                          report.connectionRoundTripTime,
                          report.localCandidateType, report.remoteCandidateType, report.transportType,
                          report.connectionSendBitrate, report.connectionReceivedBitrate]];
    
    if (session.conferenceType == QBRTCConferenceTypeVideo) {
        
        // Video send stats.
        NSString *videoSendFormat = @"VS (input) %@x%@@%@fps | (sent) %@x%@@%@fps\n"
        "VS (enc) %@/%@ | (sent) %@/%@ | %@ms | %@\n";
        [result appendString:[NSString stringWithFormat:videoSendFormat,
                              report.videoSendInputWidth, report.videoSendInputHeight, report.videoSendInputFps,
                              report.videoSendWidth, report.videoSendHeight, report.videoSendFps,
                              report.actualEncodingBitrate, report.targetEncodingBitrate,
                              report.videoSendBitrate, report.availableSendBandwidth,
                              report.videoSendEncodeMs,
                              report.videoSendCodec]];
        
        // Video receive stats.
        NSString *videoReceiveFormat =
        @"VR (recv) %@x%@@%@fps | (decoded)%@ | (output)%@fps | %@/%@ | %@ms\n";
        [result appendString:[NSString stringWithFormat:videoReceiveFormat,
                              report.videoReceivedWidth, report.videoReceivedHeight, report.videoReceivedFps,
                              report.videoReceivedDecodedFps,
                              report.videoReceivedOutputFps,
                              report.videoReceivedBitrate, report.availableReceiveBandwidth,
                              report.videoReceivedDecodeMs]];
    }
    // Audio send stats.
    NSString *audioSendFormat = @"AS %@ | %@\n";
    [result appendString:[NSString stringWithFormat:audioSendFormat,
                          report.audioSendBitrate, report.audioSendCodec]];
    
    // Audio receive stats.
    NSString *audioReceiveFormat = @"AR %@ | %@ | %@ms | (expandrate)%@";
    [result appendString:[NSString stringWithFormat:audioReceiveFormat,
                          report.audioReceivedBitrate, report.audioReceivedCodec, report.audioReceivedCurrentDelay,
                          report.audioReceivedExpandRate]];
    
    //    NSLog(@"%@", result);
}

- (OpponentCollectionViewCell *)updateStateWithSession:(QBRTCSession *)session forUserID:(NSNumber *)userID {
    
    NSParameterAssert(self.session == session);
    OpponentCollectionViewCell *cell = [self performUpdateUserID:userID];
    cell.connectionState = [self.session connectionStateForUser:userID];
    
    return cell;
}

- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
    //    [session.localMediaStream.audioTrack setAudioDataReceiver:self.recorder];
}
/**
 * Called in case when you are calling to user, but he hasn't answered
 */
- (void)session:(QBRTCSession *)session userDoesNotRespond:(NSNumber *)userID {
    [self updateStateWithSession:session forUserID:userID];
}
/**
 * Called in case when user accepted your call
 *
 */
- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    [self updateStateWithSession:session forUserID:userID];
}
/**
 * Called in case when opponent has rejected you call
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    [self updateStateWithSession:session forUserID:userID];
}

/**
 *  Called in case when opponent hung up
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    OpponentCollectionViewCell *cell = [self updateStateWithSession:session forUserID:userID];
    
    if (self.zoomedView != nil && self.zoomedViewOpponentCell == cell) {
        [self removeZoomedView];
    }
}

/**
 *  Called in case when receive remote video track from opponent
 */
- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    OpponentCollectionViewCell *cell = [self performUpdateUserID:userID];
    QBRTCRemoteVideoView *opponentVideoView = (id)[self videoViewWithOpponentID:userID];
    [cell setVideoView:opponentVideoView];
}

- (void)session:(QBRTCSession *)session receivedRemoteAudioTrack:(QBRTCAudioTrack *)audioTrack fromUser:(NSNumber *)userID {
    
}

/**
 *  Called in case when connection initiated
 */
- (void)session:(QBRTCSession *)session startedConnectionToUser:(NSNumber *)userID {
    [self updateStateWithSession:session forUserID:userID];
}

/**
 *  Called in case when connection is established with opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    [self updateStateWithSession:session forUserID:userID];
}

/**
 *  Called in case when connection state changed
 */
- (void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID {
    
    NSParameterAssert(self.session == session);
    OpponentCollectionViewCell *cell = [self performUpdateUserID:userID];
    [self.videoViews removeObjectForKey:userID];
    [cell setVideoView:nil];
}

/**
 *  Called in case when disconnected from opponent
 */
- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    [self updateStateWithSession:session forUserID:userID];
}

/**
 *  Called in case when disconnected by timeout
 */
- (void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID {
    [self updateStateWithSession:session forUserID:userID];
}

/**
 *  Called in case when connection failed with user
 */
- (void)session:(QBRTCSession *)session connectionFailedWithUser:(NSNumber *)userID {
    [self updateStateWithSession:session forUserID:userID];
}

/**
 *  Called in case when session will close
 */
- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session) {
        
        self.toolbar.userInteractionEnabled = NO;
        //        self.localVideoView.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            
            self.toolbar.alpha = 0.4;
        }];
        
        self.title = [NSString stringWithFormat:@"End - %@", [self stringWithTimeDuration:self.timeDuration]];
    }
}

#pragma mark - Timers actions

- (void)playCallingSound:(id)sender {
    
    [QMSoundManager playCallingSound];
}

- (void)refreshCallTime:(NSTimer *)sender {
    
    self.timeDuration += kRefreshTimeInterval;
    self.title = [NSString stringWithFormat:@"Call time - %@", [self stringWithTimeDuration:self.timeDuration]];
}

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {
    
    NSInteger minutes = timeDuration / 60;
    NSInteger seconds = (NSInteger)timeDuration % 60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    return timeStr;
}

- (void)localVideoView:(LocalVideoView *)localVideoView pressedSwitchButton:(UIButton *)sender {
    
    AVCaptureDevicePosition position = [self.cameraCapture currentPosition];
    AVCaptureDevicePosition newPosition = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    if ([self.cameraCapture hasCameraForPosition:newPosition]) {
        
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        if (position == AVCaptureDevicePositionFront) {
            
            animation.subtype = kCATransitionFromRight;
        }
        else if(position == AVCaptureDevicePositionBack) {
            
            animation.subtype = kCATransitionFromLeft;
        }
        
        [localVideoView.superview.layer addAnimation:animation forKey:nil];
        
        [self.cameraCapture selectCameraPosition:newPosition];
    }
}

@end
