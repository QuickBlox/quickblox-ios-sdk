//
//  BaseCallViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 22.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "BaseViewController.h"
#import "ConferenceSettings.h"
#import "ChatManager.h"
#import "ConferenceUser.h"
#import "QBUUser+Chat.h"
#import "ButtonsFactory.h"
#import "ConferenceUserCell.h"
#import "LocalVideoView.h"
#import "CallParticipants.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CompletionCallBlock)(BOOL isClosedCall);
typedef void(^CompletionActionBlock)(void);

@protocol BaseCallViewControllerDelegate <NSObject>
- (void)callVCdidAdd:(BOOL)isAdded NewPublisher:(NSNumber *)userID;
@end

@protocol ConferenceViewProtocol
@required
@property (nonatomic, strong) CompletionCallBlock didClosedCallScreen;
@end

@interface BaseCallViewController : BaseViewController <ConferenceViewProtocol>
@property (nonatomic, weak) id <BaseCallViewControllerDelegate> callViewControllerDelegate;
@property (nonatomic, strong) CompletionCallBlock didClosedCallScreen;
@property (strong, nonatomic) ConferenceSettings *conferenceSettings;
@property (strong, nonatomic) QBRTCConferenceSession * _Nullable session;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) CallParticipants *participants;
@property (assign, nonatomic) BOOL muteVideo;
@property (assign, nonatomic) BOOL muteAudio;
@property (strong, nonatomic) CustomButton *swapCamera;
@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;
//@property (strong, nonatomic) LocalVideoView * _Nullable localVideoView;
//@property (strong, nonatomic) NSMutableDictionary *videoViews;

- (instancetype)initWithConferenceSettings:(ConferenceSettings *)conferenceSettings;
- (void)didTapChat:(UIBarButtonItem *)sender;
- (void)setupSession;
- (void)setupDelegates;
- (void)addToCollectionUserWithID:(NSNumber *)userID;
- (void)addNewPublisher:(QBUUser *)user;
- (void)removeUserFromCollection:(NSNumber *)userID;
//- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID;
- (void)setupAudioVideoEnabledCell:(ConferenceUserCell *)cell forUserID:(NSNumber *)userID;
- (void)updateWithCreatedNewSession:(QBRTCConferenceSession *)session;
- (void)setupLocalMediaStreamVideoCapture;
- (void)configureToolBar;
- (void)leaveFromRoomWithAnimated:(BOOL)animated completion:(CompletionActionBlock _Nullable)completion;
//- (UIView *)userViewWithUserID:(NSNumber *)userID;
- (void)didSetMuteVideo:(BOOL)muteVideo;
- (void)cameraTurnOn:(BOOL)turnOn;
@end

NS_ASSUME_NONNULL_END
