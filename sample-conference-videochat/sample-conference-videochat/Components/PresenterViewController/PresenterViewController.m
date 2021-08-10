//
//  RootParentVC.m
//  sample-conference-videochat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "PresenterViewController.h"
#import "SplashScreenVC.h"
#import "UIColor+Chat.h"
#import "DialogsViewController.h"
#import "AuthorizationViewController.h"
#import "ChatManager.h"
#import "NotificationsProvider.h"
#import "ChatViewController.h"
#import "BaseCallViewController.h"
#import "ConferenceViewController.h"
#import "StreamInitiatorViewController.h"
#import "StreamParticipantViewController.h"
#import "Log.h"
#import "UIViewController+Alert.h"
#import "Profile.h"
#import "CallPermissions.h"

@interface CallNavigationController : UINavigationController
@end
@implementation CallNavigationController
@end

@interface ChatNavigationController : UINavigationController
@end
@implementation ChatNavigationController
@end


@interface PresenterViewController ()<NotificationsProviderDelegate, ChatManagerConnectionDelegate>
//MARK: - Properties
@property (nonatomic, strong) UIViewController *current;
@property (nonatomic, strong) DialogsViewController *dialogsVC;
@property (nonatomic, strong) NotificationsProvider *notificationsProvider;
@property (nonatomic, strong) ChatViewController *chatVC;
@property (nonatomic, strong) ChatNavigationController *chatNavVC;
@property (nonatomic, strong) BaseCallViewController *callVC;
@property (nonatomic, strong) CallNavigationController *callNavVC;
@property (nonatomic, strong) ChatManager *chatManager;

@end

@implementation PresenterViewController

//MARK: - ChatManagerConnectionDelegate
- (void)chatManagerStartAuthorization:(ChatManager *)chatManager {
    if ([self.current isKindOfClass:[SplashScreenVC class]]) {
        SplashScreenVC *splashScreenVC = (SplashScreenVC *)self.current;
        [splashScreenVC setupInfoLabelText:@"Login with current user ..."];
    }
}

- (void)chatManagerAuthorize:(ChatManager *)chatManager {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    if ([userDefaults boolForKey:kNeedUpdateToken] == NO) {
        return;
    }
    NSData *token = [userDefaults objectForKey:kToken];
    if (token == nil) {
        return;
    }
}

- (void)chatManagerAuthorizeFailed:(ChatManager *)chatManager {
    if ([self.current isKindOfClass:[SplashScreenVC class]]) {
        [Profile clear];
        [self showLoginScreen];
    }
}

- (void)chatManagerStartConnection:(ChatManager *)chatManager {
    if ([self.current isKindOfClass:[SplashScreenVC class]]) {
        SplashScreenVC *splashScreenVC = (SplashScreenVC *)self.current;
        [splashScreenVC setupInfoLabelText:@"Login into conference ..."];
    }
}

- (void)chatManagerConnect:(ChatManager *)chatManager {
    if ([self.current isKindOfClass:[SplashScreenVC class]]) {
        [self showDialogsScreen];
    };
}

- (void)chatManagerDisconnect:(ChatManager *)chatManager withLostNetwork:(BOOL)lostNetwork {
    if (lostNetwork == NO) { return; }
    if ([self.current isKindOfClass:[SplashScreenVC class]]) {
        SplashScreenVC *splashScreenVC = (SplashScreenVC *)self.current;
        [splashScreenVC setupInfoLabelText:@"Please check your Internet connection"];
    }
}

//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        Profile *profile = [[Profile alloc] init];
        self.chatManager = [ChatManager instance];
        self.chatManager.connectionDelegate = self;
        if (!profile.isFull) {
            [self showLoginScreen];
        } else {
            [self showSplashScreen];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.notificationsProvider = [[NotificationsProvider alloc] init];
    self.notificationsProvider.delegate = self;
    
    [self changeCurrentViewController:self.current];
}

// MARK: - Internal Methods
- (void)showSplashScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    SplashScreenVC *splashScreenVC = [storyboard instantiateViewControllerWithIdentifier:@"SplashScreenVC"];
    self.current = splashScreenVC;
    [self.chatManager activateAutomaticMode];
}

- (void)showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    AuthorizationViewController *authorizationVC = [storyboard instantiateViewControllerWithIdentifier:@"AuthorizationViewController"];
    [authorizationVC setOnCompleteAuth:^{
        [self showDialogsScreen];
    }];
    [self changeCurrentViewController:authorizationVC];
}

- (void)showDialogsScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsViewController *dialogsScreen = [storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    [dialogsScreen setOnSignIn:^{
        [self showLoginScreen];
    }];
    [dialogsScreen setOpenChatScreen:^(QBChatDialog * _Nonnull dialog, BOOL isNewCreated) {
        [self showChatScreen:dialog isNewCreated:isNewCreated];
    }];

    self.dialogsVC = dialogsScreen;
    
    [self changeCurrentViewController:dialogsScreen];
    [self.chatManager activateAutomaticMode];
    
    [CallPermissions checkPermissionsWithConferenceType:QBRTCConferenceTypeVideo presentingViewController:self completion:^(BOOL granted) {
        [self.notificationsProvider registerForRemoteNotifications];
    }];
}

- (void)showChatScreen:(QBChatDialog *)dialog isNewCreated:(BOOL)isNewCreated {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    self.chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    if (!self.chatVC) {
        return;
    }
    self.chatVC.dialog = dialog;
    
    __weak __typeof(self)weakSelf = self;
    [self.chatVC setDidCloseChatVC:^{
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf showDialogsScreen];
    }];
    
    [self.chatVC setDidOpenCallScreenWithSettings:^(ConferenceSettings * _Nullable settings) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (settings) {
            NSString *callConferenceID = strongSelf.callVC.conferenceSettings.conferenceInfo.conferenceID;
            if (callConferenceID) {
                if (![callConferenceID isEqualToString:settings.conferenceInfo.conferenceID])  {
                    [strongSelf showCallScreenWithSettings:settings];
                } else {
                    [strongSelf showCallScreen];
                }
            } else {
                [strongSelf showCallScreenWithSettings:settings];
            }
        } else {
            [strongSelf showCallScreen];
        }
    }];
    
    self.chatNavVC = [[ChatNavigationController alloc] initWithRootViewController:self.chatVC];
    
    [self changeCurrentViewController:self.chatNavVC];
    if (isNewCreated) {
        [self.chatVC sendAddOccupantsMessages:NSArray.new action: DialogActionTypeCreate];
    }
}

- (void)showChatScreenDidClosedCall:(BOOL)isClosedCall {
    if ([self.current isKindOfClass:[ChatNavigationController class]]) {
        self.callVC = nil;
        self.callNavVC = nil;
        self.chatVC.action = ChatActionNone;
    } else if ([self.current isKindOfClass:[CallNavigationController class]]) {
        NSArray *controllers = self.chatNavVC.viewControllers;
        NSMutableArray *newStack = [NSMutableArray array];
        if (controllers.count > 1) {
            for (UIViewController *controller in controllers) {
                [newStack addObject:controller];
                
                if ([controller isKindOfClass:[ChatViewController class]]) {
                    [self.chatNavVC setViewControllers:[newStack copy]];
                    break;
                }
            }
        }
        [self changeCurrentViewController:self.chatNavVC];
        
        if (isClosedCall == YES) {
            self.callVC = nil;
            self.callNavVC = nil;
            self.chatVC.action = ChatActionNone;
        } else {
            self.chatVC.action = ChatActionChatFromCall;
        }
    }
}

- (void)showCallScreenWithSettings:(ConferenceSettings *)callSettings {
    __weak __typeof(self)weakSelf = self;
    void(^showCallScreenCompletion)(ConferenceSettings *) = ^(ConferenceSettings *callSettings) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if (callSettings.conferenceInfo.callType.intValue == NotificationMessageTypeStartConference) {
            strongSelf.callVC = [[ConferenceViewController alloc] initWithConferenceSettings:callSettings];
        } else if (callSettings.conferenceInfo.callType.intValue == NotificationMessageTypeStartStream
                   && callSettings.conferenceInfo.initiatorID.unsignedIntValue == QBSession.currentSession.currentUserID) {
            strongSelf.callVC = [[StreamInitiatorViewController alloc] initWithConferenceSettings:callSettings];
        } else {
            strongSelf.callVC = [[StreamParticipantViewController alloc] initWithConferenceSettings:callSettings];
        }
        strongSelf.callNavVC = [[CallNavigationController alloc] initWithRootViewController:strongSelf.callVC];
        
        strongSelf.callVC.conferenceSettings = callSettings;
        [strongSelf.callVC setDidClosedCallScreen:^(BOOL isClosedCall) {
            [strongSelf showChatScreenDidClosedCall:isClosedCall];
        }];
        
        [strongSelf changeCurrentViewController:strongSelf.callNavVC];
    };
    
    NSString *callConferenceID = self.callVC.conferenceSettings.conferenceInfo.conferenceID;
    if (callConferenceID) {
        if (![callConferenceID isEqualToString:callSettings.conferenceInfo.conferenceID])  {
            __weak __typeof(self)weakSelf = self;
            [self.callVC leaveFromRoomWithAnimated:NO completion:^{
                __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.callVC = nil;
                strongSelf.callNavVC = nil;
                showCallScreenCompletion(callSettings);
            }];
        }
    } else if (!self.callVC) {
        showCallScreenCompletion(callSettings);
    }
}

- (void)showCallScreen {
    if (!self.callVC && !self.callNavVC) {
        return;
    }
    
    NSArray *controllers = self.callNavVC.viewControllers;
    NSMutableArray *newStack = [NSMutableArray array];
    
    //change stack by replacing view controllers after CallViewController
    if (controllers.count > 1) {
        for (UIViewController *controller in controllers) {
            [newStack addObject:controller];
            
            if ([controller isKindOfClass:[BaseCallViewController class]]) {
                [self.callNavVC setViewControllers:[newStack copy]];
                break;
            }
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.callVC setDidClosedCallScreen:^(BOOL isClosedCall) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf showChatScreenDidClosedCall:isClosedCall];
    }];
    
    [self changeCurrentViewController:self.callNavVC];
}

//MARK - Setup
- (void)changeCurrentViewController:(UIViewController *)newCurrentViewController {
    UIViewController *new = [self.current isEqual:newCurrentViewController] ? newCurrentViewController :
    [newCurrentViewController isKindOfClass:[UINavigationController class]] ? newCurrentViewController :
    [[UINavigationController alloc] initWithRootViewController:newCurrentViewController];
    if ([new isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationVC = (UINavigationController *)new;
        navigationVC.navigationBar.barStyle = UIBarStyleBlack;
        [navigationVC.navigationBar setTranslucent:NO];
        navigationVC.navigationBar.barTintColor = [UIColor mainColor];
        navigationVC.navigationBar.shadowImage = [UIImage imageNamed:@"navbar-shadow"];
        navigationVC.navigationBar.tintColor = UIColor.whiteColor;
        navigationVC.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    }
    [self addChildViewController:new];
    new.view.frame = self.view.bounds;
    [self.view addSubview:new.view];
    [new didMoveToParentViewController:self];
    
    if ([self.current isEqual:new]) {
        return;
    }
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    self.current = new;
}

- (void)handlePush:(NSString *)dialogID {
    self.callVC != nil ? [self showCallScreen] : [self showDialogsScreen];
}

//MARK: - NotificationsProviderDelegate
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceive:(NSString *)message {
    if (!message.length) {
        return;
    }
    [self handlePush:message];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
