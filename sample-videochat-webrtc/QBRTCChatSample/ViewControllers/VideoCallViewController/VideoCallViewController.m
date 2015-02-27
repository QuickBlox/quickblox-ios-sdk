//
//  CallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "VideoCallViewController.h"
#import "OpponentCollectionViewCell.h"
#import "UserPicView.h"
#import "ConnectionManager.h"
#import "SVProgressHUD.h"
#import "IAButton.h"
#import "QMSoundManager.h"

NSString *const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";

@interface VideoCallViewController ()

<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet UserPicView *oponentContainerView;
@property (weak, nonatomic) IBOutlet QBGLVideoView *opponentVideoView;
@property (weak, nonatomic) IBOutlet QBGLVideoView *localVideoView;

@property (weak, nonatomic) IBOutlet IAButton *switchAudioOutputBtn;
@property (weak, nonatomic) IBOutlet IAButton *switchCameraBtn;
@property (weak, nonatomic) IBOutlet IAButton *declineBtn;
@property (weak, nonatomic) IBOutlet IAButton *microphoneBtn;
@property (weak, nonatomic) IBOutlet IAButton *enableVideoBtn;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;

@property (strong, nonatomic) NSMutableDictionary *videoTracks;
@property (strong, nonatomic) QBRTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) NSMutableSet *connectedUsers;

@end

@implementation VideoCallViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QBRTCClient.instance addDelegate:self];
    
    self.videoTracks = [NSMutableDictionary dictionary];
    self.connectedUsers = [NSMutableSet set];
    
    QBUUser *caller  = [ConnectionManager.instance userWithID:self.session.callerID];
    [ConnectionManager.instance.me isEqual:caller] ? [self startCall] : [self acceptCall];
    self.oponentContainerView.hidden = NO;
    
    [self configureGUI];
}

- (void)startCall {
    
    self.users = [ConnectionManager.instance usersWithIDS:self.session.opponents];
    
    NSDictionary *userInfo = @{ @"userName" : ConnectionManager.instance.me.fullName };
    [self.session startCall:userInfo];
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
    [self configureOpponentContainerView];
    
    [self viewWillTransitionToSize:self.view.frame.size];
}

- (void)configureOpponentContainerView {
    
    QBUUser *user = self.users.firstObject;
    self.oponentContainerView.picColor = user.color;
    
    self.selectedItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
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
    UIColor *graySelectedColor = [UIColor colorWithWhite:0.502 alpha:0.640];
    UIColor *redBG = [UIColor colorWithRed:0.906 green:0.000 blue:0.191 alpha:1.000];
    UIColor *redSelected = [UIColor colorWithRed:0.916 green:0.668 blue:0.683 alpha:1.000];
    
    //Configure buttons
    [self configureAIButton:self.declineBtn
              withImageName:@"decline"
                    bgColor:redBG
              selectedColor:redSelected];
    
    [self configureAIButton:self.microphoneBtn
              withImageName:@"mute"
                    bgColor:nil
              selectedColor:graySelectedColor];
    self.microphoneBtn.isPushed = YES;
    
    [self configureAIButton:self.switchCameraBtn
              withImageName:@"switchCamera"
                    bgColor:nil
              selectedColor:graySelectedColor];
    self.microphoneBtn.isPushed = YES;
    
    [self configureAIButton:self.switchAudioOutputBtn
              withImageName:@"dynamic"
                    bgColor:nil
              selectedColor:graySelectedColor];
    self.switchAudioOutputBtn.isPushed = YES;
    
    [self configureAIButton:self.enableVideoBtn
              withImageName:@"video"
                    bgColor:nil
              selectedColor:graySelectedColor];
    self.enableVideoBtn.isPushed = YES;
}

#pragma mark - Actions

- (IBAction)pressMicBtn:(IAButton *)sender {
    
    self.session.audioEnabled = !self.session.audioEnabled;
}

- (IBAction)pressEnableVideoBtn:(IAButton *)sender {
    
    self.session.videoEnabled = !self.session.videoEnabled;
}

- (IBAction)pressHandUpBtn:(IAButton *)sender {
    
    [self.session hangUp:@{@"peer" : @"bue"}];
}

- (IBAction)pressSwitchCameraBtn:(IAButton *)sender {

    [self.session switchCamera:^(BOOL isFrontCamera) {
        
        NSLog(@"Is front camera - %d", isFrontCamera);
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
    QBRTCVideoTrack *videoTrack = self.videoTracks[userID];
    
    //User connection indicator
    BOOL connected = [self.connectedUsers containsObject:userID];
    cell.connected = connected;
    //User marker

    [cell setColorMarkerText:[NSString stringWithFormat:@"%lu", (unsigned long)user.index + 1]
                    andColor:user.color];
    //Selected
    if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
        
        cell.selected = YES;

        [cell setVideoTrack:nil];
        [self.opponentVideoView setVideoTrack:videoTrack];
    }
    else {
        
        cell.selected = NO;
        
        QBUUser *selectedUser = self.users[self.selectedItemIndexPath.row];
        [cell setVideoTrack:[user isEqual:selectedUser] ? nil : videoTrack];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // always reload the selected cell, so we will add the border to that cell
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath.copy];
    
    if (self.selectedItemIndexPath) {
        // if we had a previously selected cell
        
        if ([indexPath compare:self.selectedItemIndexPath] == NSOrderedSame)
        {
            // if it's the same as the one we just tapped on, then we're unselecting it
            return;
        }
        else {
            // if it's different, then add that old one to our list of cells to reload, and
            // save the currently selected indexPath
            
            [indexPaths addObject:self.selectedItemIndexPath.copy];
            self.selectedItemIndexPath = indexPath.copy;
        }
    }
    else {
        // else, we didn't have previously selected cell, so we only need to save this indexPath for future reference
        self.selectedItemIndexPath = indexPath.copy;
    }
    
    QBUUser *user = self.users[indexPath.row];
    
    self.oponentContainerView.picColor = user.color;
    
    // and now only reload only the cells that need updating
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
    [flowLayout setScrollDirection:size.width > size.height ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal];
    [self.opponentsCollectionView setCollectionViewLayout:flowLayout];
}

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {
    
    QBUUser *user = [ConnectionManager.instance userWithID:userID];
    NSUInteger idx = [self.users indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

#pragma mark - QBWebRTCChatDelegate

- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
    
    self.localVideoTrack = videoTrack;
    
    if ([self isViewLoaded]) {
        [self.localVideoView setVideoTrack:videoTrack];
    }
}

- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    self.videoTracks[userID] = videoTrack;
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    [self.opponentsCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)session:(QBRTCSession *)session startConnectToUser:(NSNumber *)userID {
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    [self.opponentsCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
    NSAssert(![self.connectedUsers containsObject:userID], @"User contains!");
    [self.connectedUsers addObject:userID];
    
    NSMutableArray *users = self.users.mutableCopy;
    NSIndexPath *indexPath2 = [self indexPathAtUserID:userID];
    
    QBUUser *user = [users objectAtIndex:indexPath2.row];
    [users removeObject:user];
    [users insertObject:user atIndex:0];
    self.users = users;
    [self.opponentsCollectionView reloadData];
}

- (void)session:(QBRTCSession *)session userDisconnected:(NSNumber *)userID {
    
    BOOL contains = [self.connectedUsers containsObject:userID];
    
    if (contains) {
        [self.connectedUsers removeObject:userID];
    }
    
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    [self.opponentsCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)session:(QBRTCSession *)session userDidNotAnswer:(NSNumber *)userID {
    
    [self removeUserWithID:userID];
}

- (void)session:(QBRTCSession *)session userHangUp:(NSNumber *)userID {
    
    [self removeUserWithID:userID];
}

- (void)session:(QBRTCSession *)session didRejectByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    [self removeUserWithID:userID];
}

- (void)removeUserWithID:(NSNumber *)userID {
    
    QBUUser *user = [ConnectionManager.instance userWithID:userID];
    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    
    NSMutableArray *users = self.users.mutableCopy;
    [users removeObject:user];
    
    self.users = users.copy;
    
    [self.opponentsCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

@end
