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
#import <mach/mach.h>
#import "QBCore.h"

NSString *const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";
NSString *const kSharingViewControllerIdentifier = @"SharingViewController";

const NSTimeInterval kRefreshTimeInterval = 1.f;

@interface CallViewController ()

<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCClientDelegate, LocalVideoViewDelegate>

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

@property (strong, nonatomic) QBButton *videoEnabled;
@property (weak, nonatomic) LocalVideoView *localVideoView;

@end

@implementation CallViewController

- (void)dealloc {
    
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QBRTCClient.instance addDelegate:self];
    
    [self configureGUI];
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        
#if !(TARGET_IPHONE_SIMULATOR)
        Settings *settings = Settings.instance;
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:settings.videoFormat
                                                                    position:settings.preferredCameraPostion];
        [self.cameraCapture startSession];
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
    
    [QBRTCSoundRouter.instance initialize];

    BOOL isInitiator = (Core.currentUser.ID == self.session.initiatorID.unsignedIntegerValue);
    isInitiator ? [self startCall] : [self acceptCall];
    
    self.title = @"Connecting...";
    
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
        
        QBRTCVideoTrack *remoteVideoTrak = [self.session remoteVideoTrackWithUserID:opponentID];
        
        if (!result && remoteVideoTrak) {
            
            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:CGRectMake(2, 2, 2, 2)];
            self.videoViews[opponentID] = remoteVideoView;
            result = remoteVideoView;
        }
        
        [remoteVideoView setVideoTrack:remoteVideoTrak];
        
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
    
    [QMSysPlayer stopAllSounds];
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
    
    [self.toolbar addButton:[QBButtonsFactory auidoEnable] action: ^(UIButton *sender) {
        
        weakSelf.session.localMediaStream.audioTrack.enabled ^=1;
    }];
    
    [self.toolbar addButton:[QBButtonsFactory dynamicEnable] action:^(UIButton *sender) {
        
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
        
        [weakSelf.callTimer invalidate];
        weakSelf.callTimer = nil;
        
        [weakSelf.session hangUp:@{@"hangup" : @"hang up"}];
    }];
    
    [self.toolbar updateItems];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    
    OpponentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
                                                                                 forIndexPath:indexPath];
    QBUUser *user = self.users[indexPath.row];
    
    [cell setVideoView:[self videoViewWithOpponentID:@(user.ID)]];
    
    return cell;
}

#pragma mark - Transition to size

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

#pragma Statistic

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
    vm_deallocate(task, (vm_address_t)thread_array, sizeof(thread_act_t) * thread_count);
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
    
    /* Example output
     2016-10-10 15:13:18.718 sample-videochat-webrtc[18260:3097814] (cpu)59%
     CN 41ms | local->local/udp | (s)5Kbps | (r)1.54Mbps
     VS (input) 0x0@0fps | (sent) 0x0@0fps
     VS (enc) 0bps/0bps | (sent) 0bps/300Kbps | 5ms | VP8
     VR (recv) 480x640@30fps | (decoded)31 | (output)31fps | 1.49Mbps/1.68Mbps | 16ms
     AS 0bps | opus
     AR 31Kbps | opus | 782ms | (expandrate)0.0278931
     */
    
    NSLog(@"%@", result);
}

- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    
    session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
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
 *  Called in case when connection initiated
 */
- (void)session:(QBRTCSession *)session startedConnectionToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
            cell.connectionState = [self.session connectionStateForUser:userID];
        }];
    }
}

/**
 *  Called in case when connection is established with opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
    NSParameterAssert(self.session == session);
    
    if (self.beepTimer) {
        
        [self.beepTimer invalidate];
        self.beepTimer = nil;
        [QMSysPlayer stopAllSounds];
    }
    
    if (!self.callTimer) {
        
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
        
        [QBRTCSoundRouter.instance deinitialize];
        
        if (self.beepTimer) {
            
            [self.beepTimer invalidate];
            self.beepTimer = nil;
            [QMSysPlayer stopAllSounds];
        }
        
        [self.callTimer invalidate];
        self.callTimer = nil;
        
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
    
    //    [QMSoundManager playCallingSound];
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
