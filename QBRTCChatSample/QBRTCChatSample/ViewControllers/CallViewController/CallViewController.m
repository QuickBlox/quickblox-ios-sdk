//
//  CallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "CallViewController.h"
#import "OpponentCollectionViewCell.h"
#import "UserPicView.h"
#import "ConnectionManager.h"
#import "SVProgressHUD.h"
#import "IAButton.h"
#import "QMSoundManager.h"

NSString *const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";
const NSTimeInterval kRefreshTimeInterval = 1.f;

@interface CallViewController ()

<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet QBGLVideoView *opponentVideoView;
@property (weak, nonatomic) IBOutlet QBGLVideoView *localVideoView;

@property (weak, nonatomic) IBOutlet IAButton *microphoneBtn;
@property (weak, nonatomic) IBOutlet IAButton *switchAudioOutputBtn;
@property (weak, nonatomic) IBOutlet IAButton *enableVideoBtn;
@property (weak, nonatomic) IBOutlet IAButton *declineBtn;

@property (weak, nonatomic) IBOutlet UILabel *callTimeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *micItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *audioOutputItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *declineItem;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;

@property (strong, nonatomic) NSTimer *callTimer;

@property (assign, nonatomic) NSTimeInterval timeDuration;
@property (assign, nonatomic) NSTimer *beepTimer;

@end

@implementation CallViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QBRTCClient.instance addDelegate:self];
    
    self.selectedItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    QBUUser *caller  = [ConnectionManager.instance userWithID:self.session.callerID];
    [ConnectionManager.instance.me isEqual:caller] ? [self startCall] : [self acceptCall];
    
    [self configureGUI];
}

- (void)beep:(NSTimer *)timer {
    
    [QMSoundManager playCallingSound];
}

- (void)startCall {
    
    self.users = [ConnectionManager.instance usersWithIDS:self.session.opponents];
    
    NSDictionary *userInfo = @{ @"userName" : ConnectionManager.instance.me.fullName };
    [self.session startCall:userInfo];
    
    self.beepTimer =
    [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                     target:self
                                   selector:@selector(beep:)
                                   userInfo:nil
                                    repeats:YES];
    
    [QMSoundManager playCallingSound];
}

- (void)acceptCall {
    
    [[QMSoundManager shared] stopAllSounds];
    
    NSMutableArray *usersIDS = self.session.opponents.mutableCopy;
    
    NSNumber *me = @(ConnectionManager.instance.me.ID);
    [usersIDS removeObject:me];
    
    [usersIDS addObject:self.session.callerID];
    
    self.users =  [ConnectionManager.instance usersWithIDS:usersIDS];
    
    QBUUser *currentUser = ConnectionManager.instance.me;
    
    NSDictionary *userInfo = @{ @"userName" : currentUser.fullName };
    [self.session acceptCall:userInfo];
}

- (void)configureGUI {
    
    [self configureNavigationBar];
    [self configureLocalVideoView];
    [self configureToolBar];
    
    self.localVideoView.hidden = YES;
    self.callTimeLabel.text = @"";
    self.callTimeLabel.hidden = YES;
    [self viewWillTransitionToSize:self.view.frame.size];
}

- (void)configureNavigationBar {
    
    self.title = [NSString stringWithFormat:@"Logged in as %@", ConnectionManager.instance.me.fullName];
    
    __weak __typeof(self)weakSelf = self;
    [self setDefaultBackBarButtonItem:^{
        
        [weakSelf.navigationController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }];
}

- (void)configureLocalVideoView {
    // drop shadow
    [self.localVideoView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.localVideoView.layer setShadowOpacity:0.8];
    [self.localVideoView.layer setShadowRadius:3.0];
    [self.localVideoView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)configureToolBar {
    //Configure toolbar
    [self.toolbar setBackgroundImage:[[UIImage alloc] init]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    
    [self.toolbar setShadowImage:[[UIImage alloc] init]
              forToolbarPosition:UIToolbarPositionAny];
    UIColor *gSelected = [UIColor colorWithWhite:0.502 alpha:0.640];
    UIColor *redBG = [UIColor colorWithRed:0.906 green:0.000 blue:0.191 alpha:0.8];
    UIColor *redSelected = [UIColor colorWithRed:0.916 green:0.668 blue:0.683 alpha:1.f];
    UIColor *bg = [UIColor colorWithWhite:1.000 alpha:0.840];
    
    //Configure buttons
    [self configureAIButton:self.declineBtn
              withImageName:@"decline"
                    bgColor:redBG
              selectedColor:redSelected];
    
    [self configureAIButton:self.microphoneBtn
              withImageName:@"mute"
                    bgColor:bg
              selectedColor:gSelected];
    self.microphoneBtn.isPushed = YES;
    
    [self configureAIButton:self.switchAudioOutputBtn
              withImageName:@"dynamic"
                    bgColor:bg
              selectedColor:gSelected];
    self.switchAudioOutputBtn.isPushed = YES;
    
    if (self.session.conferenceType == QBConferenceTypeAudio) {
        
        UIBarButtonItem *fs =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        //Update tool bar
        NSArray *items = @[fs, self.micItem, fs, self.audioOutputItem, fs, self.declineItem, fs];
        
        [self.toolbar setItems:items];
    }
    else {
        
        [self configureAIButton:self.enableVideoBtn
                  withImageName:@"video"
                        bgColor:bg
                  selectedColor:gSelected];
        
        self.enableVideoBtn.isPushed = YES;
    }
}

#pragma mark - Actions

- (IBAction)pressMicBtn:(IAButton *)sender {
    
    self.session.audioEnabled = !self.session.audioEnabled;
}

- (IBAction)pressEnableVideoBtn:(IAButton *)sender {
    
    self.session.videoEnabled = !self.session.videoEnabled;
}

- (IBAction)pressHandUpBtn:(IAButton *)sender {
    
    [self.callTimer invalidate];
    self.callTimer = nil;
    
    [self.session hangUp:@{@"session" : @"hang up"}];
}

- (IBAction)pressSwitchCameraBtn:(UIButton *)sender {
    
    sender.enabled = NO;
    
    [self.session switchCamera:^(BOOL isFrontCamera) {
        NSLog(@"Is front camera - %d", isFrontCamera);
        sender.enabled = YES;
    }];
}

- (IBAction)pressSwitchAudioOutput:(id)sender {
    
    [self.session switchAudioOutput:^(BOOL isSpeaker) {
        
        NSLog(@"Is speaker - %d", isSpeaker);
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OpponentCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
                                              forIndexPath:indexPath];
    
    QBUUser *user = self.users[indexPath.row];
    
    NSNumber *userID = @(user.ID);
    QBRTCVideoTrack *videoTrack = [self.session remoteVideoTrackWithUserID:userID];
    
    //User connection indicator
    cell.connectionState = [self.session connectionStateForUser:userID];
    
    if (cell.tag == 0) {
        cell.tag = indexPath.row + 1;
    }
    
    //User marker
    [cell setColorMarkerText:[NSString stringWithFormat:@"%lu", (unsigned long)user.index + 1]
                    andColor:user.color];
    //Selected
    if (self.selectedItemIndexPath != nil &&
        [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
        
        cell.selected = YES;
        [self.opponentVideoView setVideoTrack:videoTrack];
    }
    else {
        
        cell.selected = NO;
        [cell setVideoTrack:videoTrack];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath.copy];
    
    if (self.selectedItemIndexPath) {
        
        if ([indexPath compare:self.selectedItemIndexPath] == NSOrderedSame){
            return;
        }
        else {
            
            [indexPaths addObject:self.selectedItemIndexPath.copy];
            self.selectedItemIndexPath = indexPath.copy;
        }
    }
    else {
        
        self.selectedItemIndexPath = indexPath.copy;
    }
    
    [collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(110, 110);
}

#pragma mark - Transition to size

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Place code here to perform animations during the rotation. You can leave this block empty if not necessary.
        
        [self viewWillTransitionToSize:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size  {
    
    [self.opponentsCollectionView.collectionViewLayout invalidateLayout];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    if (size.width > size.height) {
        
        self.opponentVideoView.contentMode = UIViewContentModeScaleAspectFit;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    }
    else {
        
        self.opponentVideoView.contentMode = UIViewContentModeScaleAspectFill;
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    
    [self.opponentsCollectionView setCollectionViewLayout:flowLayout];
}

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {
    
    QBUUser *user = [ConnectionManager.instance userWithID:userID];
    NSUInteger idx = [self.users indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

#pragma mark - QBWebRTCChatDelegate

/**
 * Called in case when you are calling to user, but he hasn't answered
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session userDoesNotRespond:(NSNumber *)userID {
    
    if (session == self.session) {
        [self reloadWithUserID:userID];
    }
}

/**
 * Called in case when opponent has rejected you call
 *
 * @param userID ID of opponent
 */
- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    if (session == self.session) {
        [self reloadWithUserID:userID];
    }
}

/**
 *  Called in case when opponent hung up
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID {
    
    if (self.session == session) {
        [self reloadWithUserID:userID];
    }
}

/**
 *  Called in case when receive local video track
 *
 *  @param videoTrack
 */
- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
    
    NSAssert(self.session == session, @"Need update this case");
    self.localVideoView.hidden = NO;
    [self.localVideoView setVideoTrack:videoTrack];
}

/**
 *  Called in case when receive remote video track from opponent
 *
 *  @param videoTrack QBRTCVideoTrack instance
 *  @param userID     ID of opponent
 */

- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    NSAssert(self.session == session, @"Need update this case");
    [self reloadWithUserID:userID];
}

/**
 *  Called in case when connection initiated
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session startConnectionToUser:(NSNumber *)userID {
    
    NSAssert(self.session == session, @"Need update this case");
    [self reloadWithUserID:userID];
}

/**
 *  Called in case when connection is established with opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
    NSAssert(self.session == session, @"Need update this case");
   
    if (self.beepTimer) {
        
        [self.beepTimer invalidate];
        self.beepTimer = nil;
        [[QMSoundManager shared] stopAllSounds];
    }
    
    if (!self.callTimer) {
        
        
        self.callTimeLabel.hidden = NO;
        self.callTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval
                                                          target:self
                                                        selector:@selector(refreshCallTime:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    
    [self reloadWithUserID:userID];
}

/**
 *  Called in case when disconnected from opponent
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    
    NSAssert(self.session == session, @"Need update this case");
    [self reloadWithUserID:userID];
}

/**
 *  Called in case when disconnected by timeout
 *
 *  @param session QBRTCSession instance
 *  @param userID  QBRTCSession instance
 */
- (void)session:(QBRTCSession *)session disconnectTimeoutForUser:(NSNumber *)userID {
    
    NSAssert(self.session == session, @"Need update this case");
    [self reloadWithUserID:userID];
}

/**
 *  Called in case when connection failed with user
 *
 *  @param session QBRTCSession instance
 *  @param userID  ID of opponent
 */
- (void)session:(QBRTCSession *)session connectionFailedWithUser:(NSNumber *)userID {
    
    NSAssert(self.session == session, @"Need update this case");
    [self reloadWithUserID:userID];
}

/**
 *  Called in case when session will close
 *
 *  @param session QBRTCSession instance
 */
- (void)sessionWillClose:(QBRTCSession *)session {
    
    if (session == self.session) {
        
        if (self.beepTimer) {
            
            [self.beepTimer invalidate];
            self.beepTimer = nil;
            [[QMSoundManager shared] stopAllSounds];
        }
        
        [self.callTimer invalidate];
        self.callTimer = nil;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.toolbar.hidden = YES;
            self.localVideoView.hidden = YES;
        }];
        
        self.callTimeLabel.text = [NSString stringWithFormat:@"End - %@", [self stringWithTimeDuration:self.timeDuration]];
    }
}

- (void)reloadWithUserID:(NSNumber *)userID {
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    [self.opponentsCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - refresh call time

- (void)refreshCallTime:(NSTimer *)timer {
    
    self.timeDuration += kRefreshTimeInterval;
    self.callTimeLabel.text = [NSString stringWithFormat:@"Call time - %@", [self stringWithTimeDuration:self.timeDuration]];
}

- (NSString *)stringWithTimeDuration:(NSTimeInterval )timeDuration {
    
    NSInteger minutes = timeDuration / 60;
    NSInteger seconds = (NSInteger)timeDuration % 60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    return timeStr;
}

@end
