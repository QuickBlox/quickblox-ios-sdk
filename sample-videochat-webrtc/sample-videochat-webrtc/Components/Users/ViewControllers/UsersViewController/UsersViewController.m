//
//  UsersViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UsersViewController.h"
#import <PushKit/PushKit.h>
#import "CallPermissions.h"
#import "CallViewController.h"
#import "UIViewController+InfoScreen.h"
#import "Profile.h"
#import "Log.h"
#import "AppDelegate.h"
#import "CallHelper.h"
#import "SearchBarView.h"
#import "CallGradientView.h"
#import "ConnectionModule.h"
#import "SearchUsersViewController.h"
#import "UserListViewController.h"
#import "SelectedUsersView.h"
#import "QBUUser+Videochat.h"
#import "SelectedUsersCountAlert.h"
#import "TitleView.h"
#import "VideoCallViewController.h"
#import "Users.h"
#import "UIViewController+Alert.h"
#import "ProgressView.h"
#import "ConnectionModule.h"
#import "AuthModule.h"
#import "SplashScreenViewController.h"
#import "NSError+Videochat.h"

#define callInfoKey( prop ) NSStringFromSelector(@selector(prop))

const NSUInteger kQBPageSize = 100;
NSString *const kStillConnection = @"Still in connecting state,\n please wait";
NSString *const kNoInternet = @"No Internet Connection \n Make sure your device is connected to the internet";
NSString *const kReconnection = @"Reconnecting state, please wait";

typedef void(^CallerNameCompletion)(NSString *callerName);

@interface UsersViewController () <PKPushRegistryDelegate, SearchBarViewDelegate, AuthModuleDelegate, ConnectionModuleDelegate>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet SearchBarView *searchBarView;
@property (weak, nonatomic) IBOutlet UIButton *videoCallButton;
@property (weak, nonatomic) IBOutlet UIButton *audioCallButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet CallGradientView *gradientView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

//MARK: - Properties
@property (strong, nonatomic) PKPushRegistry *voipRegistry;

@property (strong, nonatomic) CallHelper *callHelper;
@property (strong, nonatomic) CallViewController *callViewController;
@property (strong, nonatomic) UserListViewController *current;
@property (strong, nonatomic) SelectedUsersView *selectedUsersView;
@property (strong, nonatomic) TitleView *navigationTitleView;
@property (strong, nonatomic) Users *users;

@property (strong, nonatomic) ConnectionModule *connection;
@property (strong, nonatomic) AuthModule *authModule;
@property (strong, nonatomic) SplashScreenViewController *splashVC;
@property (nonatomic, strong) ProgressView *progressView;

@end

@interface UsersViewController (CallHelper) <CallHelperDelegate>
@end

@implementation UsersViewController
//MARK - Setup
- (void)setCurrent:(UserListViewController *)current {
    _current = current;
    [self.current setupSelectedUsers:self.users.selected.allObjects];
    
    __weak __typeof(self)weakSelf = self;
    [_current setOnSelectUser:^(QBUUser * _Nonnull user, BOOL isSelect) {
        if (!isSelect) {
            [weakSelf.users.selected removeObject:user];
            [weakSelf.selectedUsersView removeViewWithUserID:user.ID];
            return;
        }
        if (weakSelf.users.selected.count > 2) {
            [weakSelf showMaxCountAlert];
            return;}
        [weakSelf.users.selected addObject:user];
        [weakSelf.selectedUsersView addViewWithUserID:user.ID userName:user.name];
    }];
    
    [_current setOnFetchedUsers:^(NSArray<QBUUser *> * _Nonnull users) {
        Profile *profile = [[Profile alloc] init];
        for (QBUUser *user in users) {
            if (user.ID == profile.ID) { continue; }
            weakSelf.users.users[@(user.ID)] = user;
        }
    }];
}

//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    UserListViewController *fetchUsersViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
    self.current = fetchUsersViewController;
    [self changeCurrentViewController:fetchUsersViewController];
    
    self.authModule = [[AuthModule alloc] init];
    self.authModule.delegate = self;
    self.connection = [[ConnectionModule alloc] init];
    self.connection.delegate = self;
    if (self.connection.established == NO) {
        [self showSplashScreen];
    }
    [self.connection activateAutomaticMode];
    
    self.users = [[Users alloc] init];
    self.callHelper = [CallHelper new];
    self.callHelper.delegate = self;
    self.searchBarView.delegate = self;
    
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    UIColor *gradientColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.98f alpha:1.0f];
    [self.gradientView setupGradientWithFirstColor:gradientColor andSecondColor:[gradientColor colorWithAlphaComponent:0.0f]];
    self.selectedUsersView = [[NSBundle mainBundle] loadNibNamed:@"SelectedUsersView" owner:nil options:nil].firstObject;
    [self.gradientView addSubview:self.selectedUsersView];
    self.selectedUsersView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectedUsersView.leftAnchor constraintEqualToAnchor:self.gradientView.leftAnchor constant: 6.0f].active = YES;
    [self.selectedUsersView.topAnchor constraintEqualToAnchor:self.gradientView.topAnchor].active = YES;
    [self.selectedUsersView.bottomAnchor constraintEqualToAnchor:self.gradientView.bottomAnchor].active = YES;
    [self.selectedUsersView.rightAnchor constraintEqualToAnchor:self.audioCallButton.leftAnchor constant: -6.0f].active = YES;
    
    __weak __typeof(self)weakSelf = self;
    [self.selectedUsersView setOnSelectedUserViewCancelTapped:^(NSUInteger ID) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", @(ID)];
        QBUUser *user = [weakSelf.users.selected.allObjects filteredArrayUsingPredicate:predicate].firstObject;
        if (!user) {
            return;
        }
        [weakSelf.users.selected removeObject:user];
        [weakSelf.current removeSelectedUser:user];
    }];
    
    [self configureNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.callViewController = nil;
    
    [CallPermissions checkPermissionsWithConferenceType:QBRTCConferenceTypeVideo presentingViewController:self completion:^(BOOL granted) {
        if (granted) {
            Log(@"[%@] granted",  NSStringFromClass([UsersViewController class]));
        } else {
            Log(@"[%@] granted canceled",  NSStringFromClass([UsersViewController class]));
        }
    }];
}

#pragma mark - UI Configuration
- (void)showFetchScreen {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    UserListViewController *fetchUsersViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
    
    [self changeCurrentViewController:fetchUsersViewController];
}

- (void)showSearchScreenWithSearchText:(NSString *)searchText {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    SearchUsersViewController *searchUsersViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"SearchUsersViewController"];
    
    searchUsersViewController.searchText = searchText;
    [self changeCurrentViewController:searchUsersViewController];
}

- (void)changeCurrentViewController:(UserListViewController *)newCurrentViewController {
    [self addChildViewController:newCurrentViewController];
    newCurrentViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:newCurrentViewController.view];
    [newCurrentViewController didMoveToParentViewController:self];
    
    if ([self.current isEqual:newCurrentViewController]) {
        return;
    }
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    self.current = newCurrentViewController;
}

- (void)showMaxCountAlert {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    SelectedUsersCountAlert *selectedUsersCountAlert =
    [storyboard instantiateViewControllerWithIdentifier:@"SelectedUsersCountAlert"];
    selectedUsersCountAlert.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:selectedUsersCountAlert animated:NO completion:nil];
}


- (void)configureNavigationBar {
    Profile *profile = [[Profile alloc] init];
    self.navigationTitleView = [[TitleView alloc] initWithFrame:CGRectZero];
    self.navigationTitleView.text = profile.fullName;
    self.navigationItem.titleView = self.navigationTitleView;
    
    [self addInfoButton];
}

#pragma mark - Actions
- (IBAction)didPressAudioCall:(UIBarButtonItem *)sender {
    [self callWithConferenceType:QBRTCConferenceTypeAudio];
}

- (IBAction)didPressVideoCall:(UIBarButtonItem *)sender {
    [self callWithConferenceType:QBRTCConferenceTypeVideo];
}

- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType {
    __weak __typeof(self)weakSelf = self;
    if (!self.connection.established) {
        [self showNoInternetAlertWithHandler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.connection establish];
        }];
        return;
    }
    if (self.users.selected.count == 0 || self.users.selected.count > 3) {
        return;
    }
    if (self.callHelper.registeredCallId.length) {
        return;
    }
    
    [CallPermissions checkPermissionsWithConferenceType:conferenceType presentingViewController:self completion:^(BOOL granted) {
        if (!granted) {
            return;
        }
        
        [weakSelf.connection activateCallMode];
        [self.connection establish];
        
        NSMutableDictionary<NSNumber *, NSString *>*callMembers = @{}.mutableCopy;
        for (QBUUser *user in weakSelf.users.selected) {
            callMembers[@(user.ID)] = user.fullName;
        }
        
        BOOL hasVideo = conferenceType == QBRTCConferenceTypeVideo;
        [weakSelf.callHelper registerCallWithMembers:callMembers.copy
                                            hasVideo:hasVideo];
    }];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    [self logout];
}

- (void)logout {
    __weak __typeof(self)weakSelf = self;
    if (!self.connection.established) {
        [self showNoInternetAlertWithHandler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.connection establish];
        }];
        return;
    }
    self.progressView = [[NSBundle mainBundle] loadNibNamed:@"ProgressView"
                                                      owner:nil
                                                    options:nil].firstObject;
    [self.progressView start];
    
    [self deleteLastSubscriptionWithCompletion:^{
        [weakSelf.connection breakConnectionWithCompletion:^{
            [weakSelf.authModule logout];
        }];
    }];
}

- (void)showSplashScreen {
    if (self.splashVC) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    self.splashVC = [storyboard instantiateViewControllerWithIdentifier:@"SplashScreenViewController"];
    self.splashVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:self.splashVC animated:NO completion:nil];
}

- (void)hideSplashScreen {
    if (!self.splashVC) {
        return;
    }
    [self.splashVC dismissViewControllerAnimated:NO completion:^{
        self.splashVC = nil;
    }];
}

//MARK: - PKPushRegistryDelegate protocol
- (void)pushRegistry:(PKPushRegistry *)registry
didUpdatePushCredentials:(PKPushCredentials *)pushCredentials
             forType:(PKPushType)type {
    if (![type isEqualToString:PKPushTypeVoIP]) {
        return;
    }
    NSData *token = [registry pushTokenForType:PKPushTypeVoIP];
    
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    NSData *lastToken = [userDefaults objectForKey:kToken];
    if ([lastToken isEqualToData:token]) {
        return;
    }
    
    [userDefaults setObject:token forKey:kToken];
    [userDefaults setBool:YES forKey:kNeedUpdateToken];
    
    if (self.connection.tokenHasExpired) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [self deleteLastSubscriptionWithCompletion:^{
        [weakSelf createSubscriptionWithToken:token];
    }];
}

- (void)deleteLastSubscriptionWithCompletion:(void(^)(void))completion {
    NSNumber *lastSubscriptionId = [NSUserDefaults.standardUserDefaults objectForKey:kSubscriptionID];
    if (lastSubscriptionId == nil) {
        if (completion) { completion(); }
        return;
    }
    
    [QBRequest deleteSubscriptionWithID:lastSubscriptionId.unsignedIntValue
                           successBlock:^(QBResponse * _Nonnull response) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kSubscriptionID];
        Log(@"[%@] Delete Subscription request - Success",  NSStringFromClass([UsersViewController class]));
        if (completion) { completion(); }
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] Delete Subscription request - Error",  NSStringFromClass([UsersViewController class]));
        if (completion) { completion(); }
    }];
}

- (void)createSubscriptionWithToken:(NSData *)token {
    NSString *deviceUUID = UIDevice.currentDevice.identifierForVendor.UUIDString;
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceUUID;
    subscription.deviceToken = token;
    [QBRequest createSubscription:subscription
                     successBlock:^(QBResponse *response, NSArray *objects) {
        QBMSubscription *newSubscription = nil;
        for (QBMSubscription *subscription in objects) {
            if (subscription.notificationChannel == QBMNotificationChannelAPNSVOIP &&
                [subscription.deviceUDID isEqualToString:deviceUUID]) {
                newSubscription = subscription;
            }
        }
        
        [NSUserDefaults.standardUserDefaults setObject:@(newSubscription.ID) forKey:kSubscriptionID];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:kNeedUpdateToken];
        Log(@"[%@] Create Subscription request - Success",  NSStringFromClass([UsersViewController class]));
    } errorBlock:^(QBResponse *response) {
        Log(@"[%@] Create Subscription request - Error",  NSStringFromClass([UsersViewController class]));
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(nonnull PKPushPayload *)payload
             forType:(nonnull PKPushType)type
withCompletionHandler:(nonnull void (^)(void))completion {
    
    if (type != PKPushTypeVoIP) {
        completion();
        return;
    }
    
    if ([self.callHelper callReceivedWithSessionId:payload.dictionaryPayload[@"sessionID"]]) {
        // when a voip push is received with the same session
        // that has an active call at that moment
        Log(@"[%@] Received a voip push with the same session that has an active call at that moment", NSStringFromClass(CallHelper.class));
        return;
    }
    [self.connection activateCallMode];
    [self.connection establish];
    [self.callHelper registerCallWithPayload:payload.dictionaryPayload completion:completion];
}

#pragma mark SearchBarViewDelegate
- (void)searchBarView:(SearchBarView *)searchBarView didChangeSearchText:(NSString *)searchText {
    if ([self.current isKindOfClass:[SearchUsersViewController class]]) {
        SearchUsersViewController *searchUsersViewController = (SearchUsersViewController *)self.current;
        searchUsersViewController.searchText = searchText;
    } else {
        if (searchText.length > 2) {
            [self showSearchScreenWithSearchText:searchText];
        }
    }
}

- (void)searchBarView:(SearchBarView *)searchBarView didCancelSearchButtonTapped:(nonnull UIButton *)sender {
    [self showFetchScreen];
}

@end

@implementation UsersViewController (CallHelper)
- (void)helper:(CallHelper *)helper
didRegisterCall:(NSString *)callId
 mediaListener:(MediaListener *)mediaListener
mediaController:(MediaController *)mediaController
     direction:(CallDirection)direction
       members:(NSDictionary<NSNumber *,NSString *> *)members
      hasVideo:(BOOL)hasVideo {
    
    [self.connection activateCallMode];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Call" bundle:nil];
    self.callViewController = hasVideo ? [storyboard instantiateViewControllerWithIdentifier:@"VideoCallViewController"]
    : [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    [self.callViewController setupWithCallId:callId
                                     members:members
                               mediaListener:mediaListener
                             mediaController:mediaController
                                   direction:direction];
    
    if (direction == CallDirectionOutgoing) {
        [self helper:helper showCall:callId];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.users usersWithIDs:members.allKeys completion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        __typeof(weakSelf)strongSelf = weakSelf;
        NSMutableDictionary<NSNumber *, NSString *>*callMembers = @{}.mutableCopy;
        for (QBUUser *user in users) {
            callMembers[@(user.ID)] = user.name;
        }
        [strongSelf.callViewController.callInfo updateWithMembers:callMembers.copy];
        NSString *title = [callMembers.allValues componentsJoinedByString:@", "];
        [strongSelf.callHelper updateCall:callId title:title];
    }];
}

- (void)helper:(CallHelper *)helper didAcceptCall:(NSString *)callId {
    [self helper:helper showCall:callId];
}

- (void)helper:(CallHelper *)helper didUnregisterCall:(NSString *)callId {
    [self.callViewController endCall];
    [self.connection deactivateCallMode];
}

//MARK: - Internal
- (void)helper:(CallHelper *)helper showCall:(NSString *)callId {
    if ([self.callViewController.callInfo.callId isEqualToString:callId] == NO) {
        return;
    }
    [self.navigationController pushViewController:self.callViewController animated:NO];
    
    [self.current removeSelectedUsers];
    [self.users.selected removeAllObjects];
    [self.selectedUsersView clear];
    
    [self.callViewController setHangUp:^(NSString *callId) {
        [helper unregisterCall:callId userInfo:@{@"hangup" : @"hang up"}];
    }];
}

#pragma mark - AuthModuleDelegate
- (void)authModule:(AuthModule *)authModule didLoginUser:(QBUUser *)user {
    [Profile synchronizeUser:user];
    [self.connection establish];
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    if ([userDefaults boolForKey:kNeedUpdateToken] == NO) {
        return;
    }
    NSData *token = [userDefaults objectForKey:kToken];
    if (token == nil) {
        return;
    }
    [self deleteLastSubscriptionWithCompletion:^{
        [self createSubscriptionWithToken:token];
    }];
}

- (void)authModuleDidLogout:(AuthModule *)authModule {
    [self.connection deactivateAutomaticMode];
    if (self.onSignOut) {
        self.onSignOut();
    }
    [Profile clear];
    [self.progressView stop];
}

- (void)authModule:(AuthModule *)authModule didReceivedError:(NSError *)error {
    [self showUnAuthorizeAlert:error.localizedDescription logoutAction:^(UIAlertAction * _Nonnull action) {
        [self logout];
    } tryAgainAction:^(UIAlertAction * _Nonnull action) {
        Profile *profile = [[Profile alloc] init];
        [authModule loginWithFullName:profile.fullName login:profile.login];
    }];
}

#pragma mark - ConnectionModuleDelegate
- (void)connectionModuleWillConnect:(ConnectionModule *)connectionModule {
    [self showAnimatedAlertWithTitle:nil message:kStillConnection];
}

- (void)connectionModuleDidConnect:(ConnectionModule *)connectionModule {
    [self.current fetchUsers];
    [self hideAlertView];
    [self hideSplashScreen];
}

- (void)connectionModuleDidNotConnect:(ConnectionModule *)connectionModule withError:(NSError*)error {
    [self hideSplashScreen];
    if (error.isNetworkError) {
        __weak __typeof(self)weakSelf = self;
        [self showNoInternetAlertWithHandler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.connection establish];
        }];
        return;
    }
    [self showAlertWithTitle:nil message:error.localizedDescription];
}

- (void)connectionModuleWillReconnect:(ConnectionModule *)connectionModule {
    [self showAnimatedAlertWithTitle:nil message:kReconnection ];
}

- (void)connectionModuleDidReconnect:(ConnectionModule *)connectionModule {
    [self.current fetchUsers];
    [self hideAlertView];
}

- (void)connectionModuleTokenHasExpired:(ConnectionModule *)connectionModule {
    [self showSplashScreen];
    Profile *profile = [[Profile alloc] init];
    [self.authModule loginWithFullName:profile.fullName login:profile.login];
}

@end
