//
//  ConferenceViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 24.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "ConferenceViewController.h"
#import "OpponentsMediaViewController.h"

@interface ConferenceViewController ()
@property (strong, nonatomic) UIBarButtonItem *chatBarButtonItem;
@property (nonatomic, strong) id observerWillResignActive;
@property (nonatomic, strong) id observerWillActive;
@end

@implementation ConferenceViewController

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
        
        if ([weakSelf.participants participantWithId:weakSelf.participants.localId].isCameraEnabled != YES) {return;}
        weakSelf.session.localMediaStream.videoTrack.enabled = YES;
    }];
    
    self.observerWillResignActive = [center addObserverForName:UIApplicationWillResignActiveNotification
                                                        object:nil
                                                         queue:NSOperationQueue.mainQueue
                                                    usingBlock:^(NSNotification * _Nonnull note) {
        weakSelf.session.localMediaStream.videoTrack.enabled = NO;
    }];
}

- (void)configureNavigationBarItems {
    self.title = [self.chatManager.storage dialogWithID:self.conferenceSettings.conferenceInfo.chatDialogID].name;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_chat"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(didTapChat:)];
    self.navigationItem.leftBarButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"members_call"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(didTapMembers:)];
    self.navigationItem.rightBarButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)session:(__kindof QBRTCBaseSession *)session startedConnectingToUser:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    [self addToCollectionUserWithID:userID];
}

- (void)addNewPublisher:(QBUUser *)user {
    [self.participants addParticipantWithId:@(user.ID) fullName:user.fullName];
    [self reloadContent];
    if ([self.callViewControllerDelegate respondsToSelector:@selector(callVCdidAdd:NewPublisher:)]) {
        [self.callViewControllerDelegate callVCdidAdd:YES NewPublisher:@(user.ID)];
    }
}

- (void)removeUserFromCollection:(NSNumber *)userID {
    [self.participants removeParticipantWithId:userID];
    if ([self.callViewControllerDelegate respondsToSelector:@selector(callVCdidAdd:NewPublisher:)]) {
        [self.callViewControllerDelegate callVCdidAdd:NO NewPublisher:userID];
    }
}

- (void)setupAudioVideoEnabledCell:(ConferenceUserCell *)cell forUserID:(NSNumber *)userID {
    if (userID == self.participants.localId) {
        self.session.localMediaStream.videoTrack.enabled = !self.muteVideo;
    }
    cell.isMuted = [self.participants participantWithId:userID].isEnabledSound;
}

// MARK: Internal Methods
- (void)didTapMembers:(UIBarButtonItem *)sender {
    NSString *dialogID = self.conferenceSettings.conferenceInfo.chatDialogID;
    OpponentsMediaViewController *opponentsMediaViewController = [[OpponentsMediaViewController alloc] initWithDialogID:dialogID users:self.participants.participants];
    self.callViewControllerDelegate = opponentsMediaViewController;

    __weak __typeof(self)weakSelf = self;
    [opponentsMediaViewController setDidPressMuteUser:^(BOOL isMuted, NSNumber * _Nonnull userID) {
        __typeof(weakSelf)strongSelf = weakSelf;
        QBRTCAudioTrack *audioTrack = [strongSelf.session remoteAudioTrackWithUserID:userID];
        audioTrack.enabled = !isMuted;
        [strongSelf.participants participantWithId:userID].isEnabledSound = !isMuted;
        [strongSelf reloadContent];
    }];

    self.session.localMediaStream.videoTrack.enabled = NO;
    [self.navigationController pushViewController:opponentsMediaViewController animated:YES];
}

@end
