//
//  StreamInitiatorViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 24.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "StreamInitiatorViewController.h"
#import "StreamTitleView.h"

static const NSTimeInterval kRefreshTimeInterval = 2.0f;

@interface StreamInitiatorViewController ()
@property (strong, nonatomic) StreamTitleView *streamTitleView;
@property (strong, nonatomic) NSTimer *refreshLisnersTimer;
@property (assign, nonatomic) NSUInteger listenersCount;
@property (nonatomic, strong) id observerWillResignActive;
@property (nonatomic, strong) id observerWillActive;
@property (strong, nonatomic) NSNumber *currentConferenceUserID;
@end

@implementation StreamInitiatorViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setupNavigationBarWillAppear:NO];
    [self invalidateHideToolbarTimer];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (self.observerWillResignActive) {
        [defaultCenter removeObserver:(self.observerWillResignActive)];
    }
    if (self.observerWillActive) {
        [defaultCenter removeObserver:(self.observerWillActive)];
    }
}

- (void)didSetMuteVideo:(BOOL)muteVideo {
    self.session.localMediaStream.videoTrack.enabled = !muteVideo;
    [self.participants participantWithId:self.participants.localId].isCameraEnabled = !muteVideo;
    self.swapCamera.userInteractionEnabled = self.session.localMediaStream.videoTrack.enabled;
}

- (void)setupSession {
    if (!QBSession.currentSession.currentUser) {
        return;
    }
    self.currentConferenceUserID = @(QBSession.currentSession.currentUserID);
    QBUUser *currentUser = QBSession.currentSession.currentUser;
    
    // creating session
    NSString *conferenceID = self.conferenceSettings.conferenceInfo.conferenceID;
    self.session = [[QBRTCConferenceClient instance] createSessionWithChatDialogID:conferenceID conferenceType:QBRTCConferenceTypeVideo];
    if (!self.session) {
        return;
    }
    [self.participants addParticipantWithId:@(currentUser.ID) fullName:currentUser.name];
    
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    __weak __typeof(self)weakSelf = self;
    self.observerWillActive = [center addObserverForName:UIApplicationDidBecomeActiveNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification * _Nonnull note) {
        if (!weakSelf.cameraCapture) {return;}
        if ([weakSelf.participants participantWithId:weakSelf.participants.localId].isCameraEnabled != YES) {return;}
        
        weakSelf.session.localMediaStream.videoTrack.enabled = YES;
    }];
    
    self.observerWillResignActive = [center addObserverForName:UIApplicationWillResignActiveNotification
                                                  object:nil
                                                   queue:NSOperationQueue.mainQueue
                                              usingBlock:^(NSNotification * _Nonnull note) {
        if (!weakSelf.cameraCapture) {return;}
        weakSelf.session.localMediaStream.videoTrack.enabled = NO;
    }];
}

- (void)configureNavigationBarItems {
    self.streamTitleView = [[StreamTitleView alloc] init];
    self.navigationItem.titleView = self.streamTitleView;
    [self.streamTitleView setupStreamTitleViewOnLive:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_chat"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapChat:)];
    self.navigationItem.leftBarButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"0 members" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)setupAudioVideoEnabledCell:(ConferenceUserCell *)cell forUserID:(NSNumber *)userID {
    if (userID == self.currentConferenceUserID) {
        self.session.localMediaStream.videoTrack.enabled = !self.muteVideo;
    }
    cell.isMuted = !self.muteAudio;
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
    
    session.localMediaStream.audioTrack.enabled = YES;
    session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
    session.localMediaStream.videoTrack.enabled = NO;
    [session joinAsPublisher];
    
    [self createLisnersTimer];
}

- (void)createLisnersTimer {
    [self invalidateHideToolbarTimer];
    self.refreshLisnersTimer =[NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval
                                                               target:self
                                                             selector:@selector(refreshCallTime)
                                                             userInfo:nil
                                                              repeats:YES];
    
}

- (void)invalidateLisnersTimer {
    if (self.refreshLisnersTimer != nil) {
        [self.refreshLisnersTimer invalidate];
        self.refreshLisnersTimer = nil;
    }
}

//MARK: - Internal Methods
- (void)refreshCallTime {
    [self updateNumberOfLisners];
}

- (void)updateNumberOfLisners {
    __weak __typeof(self)weakSelf = self;
    [self.session listOnlineParticipantsWithCompletionBlock:^(NSArray<NSNumber *> * _Nonnull publishers, NSArray<NSNumber *> * _Nonnull listeners) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.listenersCount != listeners.count) {
            strongSelf.listenersCount = listeners.count;
            
            NSString *members = listeners.count == 1 ? @"member" : @"members";
            NSString *membersNumber = [NSString stringWithFormat:@"%@ %@", @(listeners.count), members];
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.navigationItem.rightBarButtonItem.title = membersNumber;
            });
        }
    }];
}

@end
