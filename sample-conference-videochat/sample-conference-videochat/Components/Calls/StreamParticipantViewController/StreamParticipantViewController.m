//
//  StreamParticipantViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 24.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "StreamParticipantViewController.h"
#import "StreamTitleView.h"

@interface StreamParticipantViewController ()
@property (strong, nonatomic) StreamTitleView *streamTitleView;
@end

@implementation StreamParticipantViewController

- (void)configureNavigationBarItems {
    self.streamTitleView = [[StreamTitleView alloc] init];
    self.navigationItem.titleView = self.streamTitleView;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_chat"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapChat:)];
    self.navigationItem.leftBarButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)setupSession {
    // creating session
    NSString *conferenceID = self.conferenceSettings.conferenceInfo.conferenceID;
    self.session = [[QBRTCConferenceClient instance] createSessionWithChatDialogID:conferenceID conferenceType:QBRTCConferenceTypeVideo];
    if (!self.session) {
        return;
    }
    
    [self addToCollectionUserWithID:self.conferenceSettings.conferenceInfo.initiatorID];
    [self reloadContent];
//    self.localVideoView = nil;
}

- (void)setupLocalMediaStreamVideoCapture {
    // Listner cannot stream his video
    self.session.localMediaStream.videoTrack.videoCapture = nil;
}

- (void)setupAudioVideoEnabledCell:(ConferenceUserCell *)cell forUserID:(NSNumber *)userID {
    cell.videoEnabled = YES;
    cell.isMuted = YES;
}

- (void)configureToolBar {
    __weak __typeof(self)weakSelf = self;
    
    self.muteVideo = YES;
    self.muteAudio = YES;
    
    [self.toolbar addButton:[ButtonsFactory decline] action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
        [strongSelf leaveFromRoomWithAnimated:YES completion:nil];
    }];
    
    [self.toolbar updateItems];
}

- (void)updateWithCreatedNewSession:(QBRTCConferenceSession *)session {
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
    
    session.localMediaStream.audioTrack.enabled = NO;
    session.localMediaStream.videoTrack.enabled = NO;
    
    __weak __typeof(self)weakSelf = self;
    [self.session listOnlineParticipantsWithCompletionBlock:^(NSArray<NSNumber *> * _Nonnull publishers, NSArray<NSNumber *> * _Nonnull listeners) {
        __typeof(weakSelf)strongSelf = weakSelf;
        for (NSNumber *userID in publishers) {
            if (userID.unsignedIntValue != self.conferenceSettings.conferenceInfo.initiatorID.unsignedIntValue) {
                continue;
            }
            [session subscribeToUserWithID:userID];
            break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.streamTitleView setupStreamTitleViewOnLive:publishers.count > 0];
        });
    }];
}

- (void)session:(QBRTCConferenceSession *)session didReceiveNewPublisherWithUserID:(NSNumber *)userID {
    if (session != self.session) {
        return;
    }
    [self.session subscribeToUserWithID:userID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamTitleView setupStreamTitleViewOnLive:YES];
        [self showControls:YES];
    });
    
    [self reloadContent];
}

- (void)removeUserFromCollection:(NSNumber *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamTitleView setupStreamTitleViewOnLive:NO];
        [self showControls:YES];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showControls:YES];
}

@end
