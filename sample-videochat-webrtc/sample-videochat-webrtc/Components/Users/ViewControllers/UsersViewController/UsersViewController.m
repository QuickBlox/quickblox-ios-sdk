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

#define callInfoKey( prop ) NSStringFromSelector(@selector(prop))

const NSUInteger kQBPageSize = 100;
NSString *const kNoInternetCall = @"Still in connecting state,\n please wait";
NSString *const kNoInternet = @"No Internet Connection \n Make sure your device is connected to the internet";

typedef void(^CallerNameCompletion)(NSString *callerName);

@interface UsersViewController () <PKPushRegistryDelegate, SearchBarViewDelegate>
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
@property (assign, nonatomic) BOOL isPresentAlert;
@property (strong, nonatomic) Users *users;

@property (strong, nonatomic) ConnectionModule *connection;

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

- (ConnectionModule *)connection {
    if (_connection) {
        return _connection;
    }
    _connection = [[ConnectionModule alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    
    [_connection setOnAuthorize:^{
        Log(@"[%@] [connection] On Authorize",  NSStringFromClass(weakSelf.class));
        NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
        if ([userDefaults boolForKey:kNeedUpdateToken] == NO) {
            return;
        }
        NSData *token = [userDefaults objectForKey:kToken];
        if (token == nil) {
            return;
        }
        [weakSelf deleteLastSubscriptionWithCompletion:^{
            [weakSelf createSubscriptionWithToken:token];
        }];
    }];
    
    [_connection setOnConnect:^{
        weakSelf.isPresentAlert = NO;
        weakSelf.navigationTitleView.textColor = UIColor.whiteColor;
        Log(@"[%@] [connection] On Connect",  NSStringFromClass(weakSelf.class));
        [weakSelf.current fetchUsers];
    }];
    
    [_connection setOnDisconnect:^(BOOL lostNetwork) {
        Log(@"[%@] [connection] On Disconnect",  NSStringFromClass(weakSelf.class));
        weakSelf.navigationTitleView.textColor = UIColor.orangeColor;
        if (lostNetwork == NO || weakSelf.isPresentAlert) {
            return;
        }
        weakSelf.isPresentAlert = YES;
        [weakSelf showAnimatedAlertWithTitle:nil message:kNoInternet fromViewController:weakSelf];
    }];
    
    return _connection;
}

//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.users = [[Users alloc] init];
    self.callHelper = [CallHelper new];
    self.callHelper.delegate = self;
    self.isPresentAlert = NO;
    self.searchBarView.delegate = self;
    
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    [self.connection activateAutomaticMode];
    
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
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    UserListViewController *fetchUsersViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"UserListViewController"];
    self.current = fetchUsersViewController;
    [self changeCurrentViewController:fetchUsersViewController];
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
    if (!self.connection.established) {
        [self showAnimatedAlertWithTitle:kNoInternetCall message:nil fromViewController:self];
        return;
    }
    if (self.users.selected.count == 0 || self.users.selected.count > 3) {
        return;
    }
    if (self.callHelper.registeredCallId.length) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [CallPermissions checkPermissionsWithConferenceType:conferenceType presentingViewController:self completion:^(BOOL granted) {
        if (!granted) {
            return;
        }
        
        [weakSelf.connection activateCallMode];
        [self.connection establishConnection];
        
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
    if (!self.connection.established) {
        [self showAnimatedAlertWithTitle:nil message:kNoInternetCall fromViewController:self];
        return;
    }
    ProgressView *progressView = [[NSBundle mainBundle] loadNibNamed:@"ProgressView"
                                                               owner:nil
                                                             options:nil].firstObject;
    [progressView start];
    __weak __typeof(self)weakSelf = self;
    [self deleteLastSubscriptionWithCompletion:^{
        [weakSelf.connection breakConnectionWithCompletion:^{
            [NSUserDefaults.standardUserDefaults removeObjectForKey:kToken];
            //Dismiss Settings view controller
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            [Profile clear];
            [progressView stop];
        }];
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
    [self.connection establishConnection];
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

@end
