//
//  UsersViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UsersViewController.h"
#import <Quickblox/Quickblox.h>
#import <PushKit/PushKit.h>
#import "UsersDataSource.h"
#import "PlaceholderGenerator.h"
#import "CallPermissions.h"
#import "SessionSettingsViewController.h"
#import "SVProgressHUD.h"
#import "CallViewController.h"
#import "CallKitManager.h"
#import "UIViewController+InfoScreen.h"
#import "Profile.h"
#import "Reachability.h"
#import "Log.h"
#import "AppDelegate.h"

const NSUInteger kQBPageSize = 50;
static NSString * const kAps = @"aps";
static NSString * const kAlert = @"alert";
static NSString * const kVoipEvent = @"VOIPCall";
NSString *const DEFAULT_PASSOWORD = @"quickblox";
static const NSTimeInterval kAnswerInterval = 10.0f;

typedef NS_ENUM(NSUInteger, ErrorDomain) {
    ErrorDomainSignUp,
    ErrorDomainLogIn,
    ErrorDomainLogOut,
    ErrorDomainChat,
};

typedef void(^CallerNameCompletion)(NSString *callerName);

@interface UsersViewController () <QBRTCClientDelegate, SettingsViewControllerDelegate, PKPushRegistryDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *audioCallButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *videoCallButton;

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (strong, nonatomic) UINavigationController *navViewController;
@property (weak, nonatomic) QBRTCSession *session;
@property (strong, nonatomic) NSString *sessionID;
@property (strong, nonatomic) NSTimer *answerTimer;

@property (strong, nonatomic) PKPushRegistry *voipRegistry;

@property (strong, nonatomic) NSUUID *callUUID;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (assign, nonatomic) Boolean isUpdatedPayload;

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backgroundTask = UIBackgroundTaskInvalid;
    
    [QBRTCClient.instance addDelegate:self];
    // Reachability
    __weak __typeof(self)weakSelf = self;
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        if (status != QBNetworkStatusNotReachable) {
            [weakSelf loadUsers];
        }
    };
    
    [self configureNavigationBar];
    [self configureTableViewController];
    [self setToolbarButtonsEnabled:NO];
    [self loadUsers];
    
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //MARK: - Reachability
    void (^updateConnectionStatus)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        if (status == QBNetworkStatusNotReachable) {
            [self cancelCallAlert];
        } else {
            [self loadUsers];
        }
    };
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        updateConnectionStatus(status);
    };
    
    if (self.refreshControl.refreshing) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
    self.navigationController.toolbarHidden = NO;
    self.isUpdatedPayload = YES;
    
    [CallPermissions checkPermissionsWithConferenceType:QBRTCConferenceTypeVideo completion:^(BOOL granted) {
        
        if (granted) {
            Log(@"[%@] granted",  NSStringFromClass([UsersViewController class]));
        } else {
            Log(@"[%@] granted canceled",  NSStringFromClass([UsersViewController class]));
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self invalidateAnswerTimer];
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Answer Timer
- (void)setupAnswerTimerWithTimeInterval:(NSTimeInterval)timeInterval {
    if (self.answerTimer) {
        [self.answerTimer invalidate];
        self.answerTimer = nil;
    }
    self.answerTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                        target:self
                                                      selector:@selector(endCallByTimer)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)invalidateAnswerTimer {
    if (self.answerTimer) {
        [self.answerTimer invalidate];
        self.answerTimer = nil;
    }
}

- (void)endCallByTimer {
    [self invalidateAnswerTimer];
    if (CallKitManager.instance.currentCall) {
        Call *currentCall = CallKitManager.instance.currentCall;
        [CallKitManager.instance endCallWithUUID:currentCall.uuid completion:nil];
    }
    [self prepareCloseCall];
}

#pragma mark - UI Configuration
- (void)configureTableViewController {
    
    _dataSource = [[UsersDataSource alloc] init];
    CallKitManager.instance.usersDatasource = _dataSource;
    
    self.tableView.dataSource = _dataSource;
    self.tableView.rowHeight = 44;
    [self.refreshControl beginRefreshing];
}

- (void)configureNavigationBar {
    
    UIBarButtonItem *settingsButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-settings"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didPressSettingsButton:)];
    
    self.navigationItem.leftBarButtonItem = settingsButtonItem;
    //Custom label
    
    Profile *profile = [[Profile alloc] init];
    NSString *roomName = [NSString stringWithFormat:@"%@", profile.tag];
    NSString *loggedString = [NSString stringWithFormat:@"Logged in as "];
    NSString *fullName = profile.fullName;
    NSString *titleString = [NSString stringWithFormat:@"%@%@", loggedString, fullName];
    if (profile.tag) {
        titleString = [NSString stringWithFormat:@"%@\n%@", roomName, loggedString];
    }
    
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSRange roomNameRange = [titleString rangeOfString:roomName];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:16.0f]
                       range:roomNameRange];
    
    NSRange userNameRange = [titleString rangeOfString:loggedString];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:12.0f]
                       range:userNameRange];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor grayColor]
                       range:userNameRange];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.numberOfLines = 2;
    titleView.attributedText = attrString;
    titleView.textAlignment = NSTextAlignmentCenter;
    [titleView sizeToFit];
    
    self.navigationItem.titleView = titleView;
    //Show tool bar
    self.navigationController.toolbarHidden = NO;
    //Set exclusive touch for tool bar
    for (UIView *subview in self.navigationController.toolbar.subviews) {
        [subview setExclusiveTouch:YES];
    }
    //add info button
    [self showInfoButton];
}
/**
 *  Load all (Recursive) users for current room (tag)
 */
- (void)loadUsers {
    
    QBGeneralResponsePage *firstPage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
    __weak __typeof(self)weakSelf = self;
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc date updated_at"} page:firstPage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.dataSource updateUsers:users];
        [weakSelf.tableView reloadData];
    } errorBlock:^(QBResponse * _Nonnull response) {
        [weakSelf.refreshControl endRefreshing];
    }];
}

#pragma mark - Actions

- (void)didPressRecordsButton:(UIBarButtonItem *)item {
    [self performSegueWithIdentifier:@"PresentRecordsViewController" sender:item];
}

- (IBAction)refresh:(UIRefreshControl *)sender {
    [self loadUsers];
}

- (IBAction)didPressAudioCall:(UIBarButtonItem *)sender {
    [self callWithConferenceType:QBRTCConferenceTypeAudio];
}

- (IBAction)didPressVideoCall:(UIBarButtonItem *)sender {
    [self callWithConferenceType:QBRTCConferenceTypeVideo];
}

- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType {
    if (self.session) {
        return;
    }
    
    Profile *profile = [[Profile alloc] init];
    
    if ([self hasConnectivity]) {
        
        [CallPermissions checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
            
            __weak __typeof(self)weakSelf = self;
            
            if (granted) {
                
                NSArray *opponentsIDs = [weakSelf.dataSource idsForUsers:weakSelf.dataSource.selectedUsers];
                __block NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                [self.dataSource.selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    QBUUser *user = (QBUUser *)obj;
                    [tmpArray addObject:user.fullName];
                }];
                NSArray *opponentsNames = tmpArray.copy;
                //Create new session
                QBRTCSession *session =
                [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                                 withConferenceType:conferenceType];
                if (session) {
                    
                    weakSelf.session = session;
                    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:session.ID];
                    weakSelf.callUUID = uuid;
                    
                    NSString *opponentsNamesString = [opponentsNames componentsJoinedByString:@","];
                    NSString *initiatorName = profile.fullName;
                    NSString *allUsersNamesString = [NSString stringWithFormat:@"%@,%@", initiatorName, opponentsNamesString];
                    NSString *usersIDsString = [opponentsIDs componentsJoinedByString:@","];
                    NSString *allUsersIDsString = [NSString stringWithFormat:@"%@,%@", @(profile.ID), usersIDsString];
                    NSString *conferenceTypeString = conferenceType == QBRTCConferenceTypeVideo ? @"1" : @"2";
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSString *timeStamp = [formatter stringFromDate:NSDate.date];
                    
                    NSDictionary *payload = @{
                        @"message"  : [NSString stringWithFormat:@"%@ is calling you.", initiatorName],
                        @"ios_voip" : @"1",
                        kVoipEvent  : @"1",
                        @"sessionID" : session.ID,
                        @"opponentsIDs" : allUsersIDsString,
                        @"contactIdentifier" : allUsersNamesString,
                        @"conferenceType" : conferenceTypeString,
                        @"timestamp" : timeStamp
                    };
                    NSData *data =
                    [NSJSONSerialization dataWithJSONObject:payload
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
                    NSString *message =
                    [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
                    
                    QBMEvent *event = [QBMEvent event];
                    event.notificationType = QBMNotificationTypePush;
                    event.usersIDs = usersIDsString;
                    event.type = QBMEventTypeOneShot;
                    event.message = message;
                    
                    [QBRequest createEvent:event
                              successBlock:^(QBResponse *response, NSArray<QBMEvent *> *events) {
                        Log(@"[%@] Send voip push - Success",  NSStringFromClass([UsersViewController class]));
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        Log(@"[%@] Send voip push - Error",  NSStringFromClass([UsersViewController class]));
                    }];
                    [CallKitManager.instance startCallWithUserIDs:opponentsIDs session:session uuid:uuid];
                    
                    CallViewController *callViewController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
                    callViewController.session = weakSelf.session;
                    callViewController.usersDatasource = weakSelf.dataSource;
                    callViewController.callUUID = uuid;
                    callViewController.sessionConferenceType = session.conferenceType;
                    
                    weakSelf.navViewController = [[UINavigationController alloc] initWithRootViewController:callViewController];
                    weakSelf.navViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    weakSelf.navViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    
                    [self presentViewController:self.navViewController animated:NO completion:^{
                        __weak __typeof(self)weakSelf = self;
                        weakSelf.audioCallButton.enabled = NO;
                        weakSelf.videoCallButton.enabled = NO;
                    }];
                }
                else {
                    
                    [SVProgressHUD showErrorWithStatus:@"You should login to use VideoChat API. Session hasn’t been created. Please try to relogin."];
                }
            }
        }];
    }
}

- (BOOL)hasConnectivity {
    
    BOOL hasConnectivity = Reachability.instance.networkStatus != QBNetworkStatusNotReachable;
    
    if (!hasConnectivity) {
        [self showAlertViewWithMessage:NSLocalizedString(@"Please check your Internet connection", nil)];
    }
    
    return hasConnectivity;
}

- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didPressSettingsButton:(UIBarButtonItem *)item {
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    SessionSettingsViewController *settingsController = [settingsStoryboard instantiateViewControllerWithIdentifier:@"SessionSettingsViewController"];
    settingsController.delegate = self;
    [self.navigationController pushViewController:settingsController animated:YES];
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender {
    [self logoutAction];
}

- (void)logoutAction {
    if (QBChat.instance.isConnected == NO) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
        return;
    }
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGOUTING", nil)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
#if TARGET_OS_SIMULATOR
    [self disconnectUser];
#else
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [QBRequest subscriptionsWithSuccessBlock:^(QBResponse * _Nonnull response, NSArray<QBMSubscription *> * _Nullable objects) {
        for (QBMSubscription *subscription in objects) {
            if ([subscription.deviceUDID isEqualToString:deviceIdentifier] && subscription.notificationChannel == QBMNotificationChannelAPNSVOIP) {
                [self unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier];
                return;
            }
        }
        [self disconnectUser];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.status == 404) {
            [self disconnectUser];
        }
    }];
#endif
}

- (void)unregisterSubscriptionForUniqueDeviceIdentifier:(NSString *)deviceIdentifier {
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse *response) {
        
        [self disconnectUser];
        
    } errorBlock:^(QBError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.error.localizedDescription];
            return;
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)disconnectUser {
    [QBChat.instance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        [self logOut];
    }];
}

- (void)logOut {
    __weak __typeof(self)weakSelf = self;
    [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        //ClearProfile
        [Profile clearProfile];
        [SVProgressHUD dismiss];
        //Dismiss Settings view controller
        [strongSelf dismissViewControllerAnimated:NO completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.navigationController popToRootViewControllerAnimated:NO];
        });
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Complited", nil)];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (response.error.error) {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            return;
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource selectUserAtIndexPath:indexPath];
    [self setupToolbarButtons];
    [tableView reloadData];
}

#pragma mark - QBCallKitDataSource

- (NSString *)userNameForUserID:(NSNumber *)userID sender:(id)sender {
    
    QBUUser *user = [self.dataSource userWithID:userID.unsignedIntegerValue];
    return user.fullName;
}

#pragma mark - Helpers
- (void)setToolbarButtonsEnabled:(BOOL)enabled {
    
    for (UIBarButtonItem *item in self.toolbarItems) {
        item.enabled = enabled;
    }
}

- (void)setupToolbarButtons {
    [self setToolbarButtonsEnabled:self.dataSource.selectedUsers.count > 0];
    if (self.dataSource.selectedUsers.count > 4) {
        self.videoCallButton.enabled = NO;
    }
}

- (void)loadUserWithID:(NSUInteger)ID completion:(void(^)(QBUUser * _Nullable user))completion {
    [QBRequest userWithID:ID successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        [self.dataSource updateUsers:@[user]];
        if (completion) {
            completion(user);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)cancelCallAlert {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please check your Internet connection", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
        [self prepareCloseCall];
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:NO completion:^{
    }];
}

#pragma mark - QBWebRTCChatDelegate

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary<NSString *,NSString *> *)userInfo {
    if ((session.initiatorID.unsignedIntegerValue == userID.unsignedIntegerValue
         && !CallKitManager.instance.isCallDidStarted
         && [self.sessionID isEqualToString:session.ID]) || self.isUpdatedPayload == NO) {
        [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
        [self prepareCloseCall];
    }
}

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    if (self.session != nil) {
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    [self invalidateAnswerTimer];
    
    self.session = session;
    
    // open by VIOP
    if (CallKitManager.instance.currentCall) {
        if (!CallKitManager.instance.isHasSession) {
            [CallKitManager.instance setupSession:session];
        }
        Call *currentCall = CallKitManager.instance.currentCall;
        if (currentCall.status == CallStatusEnded) {
            [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
            [session rejectCall:@{@"reject" : @"busy"}];
        } else if (currentCall.status == CallStatusActive) {
        } else if (currentCall.status == CallStatusInvite) {
            NSMutableArray *opponentIDs = [@[session.initiatorID] mutableCopy];
            Profile *profile = [[Profile alloc] init];
            
            for (NSNumber *userID in session.opponentsIDs) {
                if ([userID isEqualToNumber:@(profile.ID)]) {
                    continue;
                }
                [opponentIDs addObject:userID];
            }

            [self prepareCallerNameForOpponentIDs:opponentIDs completion:^(NSString *callerName) {
                [CallKitManager.instance updateIncomingCallWithUserIDs:opponentIDs outCallerName:callerName session:session];
            }];
        }
        
    } else {
        
        //open by call
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:session.ID];
        self.callUUID = uuid;
        
        NSMutableArray *opponentIDs = [@[session.initiatorID] mutableCopy];
        Profile *profile = [[Profile alloc] init];
        
        for (NSNumber *userID in session.opponentsIDs) {
            if ([userID isEqualToNumber:@(profile.ID)]) {
                continue;
            }
            [opponentIDs addObject:userID];
        }
        __weak __typeof(self)weakSelf = self;
        [self prepareCallerNameForOpponentIDs:opponentIDs completion:^(NSString *callerName) {
            [weakSelf reportIncomingCallWithUserIDs:opponentIDs outCallerName:callerName session:session uuid:uuid];
        }];
    }
}

- (void)prepareCallerNameForOpponentIDs:(NSArray<NSNumber *> *)opponentIDs completion:(CallerNameCompletion)completion {
    __block NSString *callerName = @"";
    NSMutableArray *opponentNames = [NSMutableArray arrayWithCapacity:opponentIDs.count];
    NSMutableArray *newUsers = [NSMutableArray array];
    for (NSNumber *userID in opponentIDs) {
        QBUUser *user = [self.dataSource userWithID:userID.unsignedIntegerValue];
        if (user) {
            [opponentNames addObject:user.fullName];
        } else {
            [newUsers addObject:userID.stringValue];
        }
    }
    
    if (newUsers.count) {
        __weak __typeof(self)weakSelf = self;
        [QBRequest usersWithIDs:newUsers page:nil successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
            if (users) {
                [weakSelf.dataSource updateUsers:users ];
                for (QBUUser *user in users) {
                    [opponentNames addObject:user.fullName];
                }
                callerName = [opponentNames componentsJoinedByString:@", "];
                if (completion) {
                    completion(callerName);
                }
            }
        } errorBlock:^(QBResponse * _Nonnull response) {
            for (NSNumber *userID in newUsers) {
                [opponentNames addObject:userID.stringValue];
            }
            callerName = [opponentNames componentsJoinedByString:@", "];
            if (completion) {
                completion(callerName);
            }
        }];
        
    } else {
        callerName = [opponentNames componentsJoinedByString:@", "];
        if (completion) {
            completion(callerName);
        }
    }
}

- (void)openCallWithSession:(QBRTCSession * _Nullable)session uuid:(NSUUID *)uuid sessionConferenceType:(QBRTCConferenceType)sessionConferenceType {
    if ([self hasConnectivity]) {
        CallViewController *callViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
        callViewController.session = session;
        callViewController.usersDatasource = self.dataSource;
        callViewController.callUUID = uuid;
        callViewController.sessionConferenceType = sessionConferenceType;
        self.navViewController = [[UINavigationController alloc] initWithRootViewController:callViewController];
        self.navViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.navViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:self.navViewController animated:NO completion:nil];
    } else {
        return;
    }
}

- (void)reportIncomingCallWithUserIDs:(NSArray *)userIDs outCallerName:(NSString *)callerName session:(QBRTCSession *)session uuid:(NSUUID *)uuid {
    __weak __typeof(self)weakSelf = self;
    [CallKitManager.instance reportIncomingCallWithUserIDs:userIDs outCallerName:callerName session:session sessionID:session.ID sessionConferenceType:session.conferenceType uuid:uuid onAcceptAction:^(Boolean isAccept) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        if (isAccept) {
            [strongSelf openCallWithSession:session uuid:uuid sessionConferenceType:session.conferenceType];
        } else {
            
        }
        
    } completion:nil];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if ([session.ID isEqualToString: self.session.ID]) {
        if (CallKitManager.instance.currentCall) {
            Call *currentCall = CallKitManager.instance.currentCall;
            [CallKitManager.instance endCallWithUUID:currentCall.uuid completion:nil];
        }
        [self prepareCloseCall];
    }
}

- (void)prepareCloseCall {
    if ([[self.navViewController presentingViewController] presentedViewController] == self.navViewController) {
        self.navViewController.view.userInteractionEnabled = NO;
        [self.navViewController dismissViewControllerAnimated:NO completion:nil];
        
    }
    self.sessionID = nil;
    self.session = nil;
    self.callUUID = nil;
    if (![QBChat instance].isConnected) {
        [self connectToChatWithSuccessCompletion:nil];
    }
    [self setupToolbarButtons];
}

// MARK: - PKPushRegistryDelegate protocol

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    
    //  New way, only for updated backend
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = [registry pushTokenForType:PKPushTypeVoIP];
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        Log(@"[%@] Create Subscription request - Success",  NSStringFromClass([UsersViewController class]));
    } errorBlock:^(QBResponse *response) {
        Log(@"[%@] Create Subscription request - Error",  NSStringFromClass([UsersViewController class]));
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] Unregister Subscription request - Success",  NSStringFromClass([UsersViewController class]));
    } errorBlock:^(QBError * _Nonnull error) {
        Log(@"[%@] Unregister Subscription request - Error",  NSStringFromClass([UsersViewController class]));
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(nonnull PKPushPayload *)payload forType:(nonnull PKPushType)type withCompletionHandler:(nonnull void (^)(void))completion {
    
    //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
    //if time delivery is more than “answerTimeInterval” - return
    if (type == PKPushTypeVoIP &&
    [payload.dictionaryPayload objectForKey:kVoipEvent] != nil &&
    [UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
        payload.dictionaryPayload[@"timestamp"] != nil &&
        payload.dictionaryPayload[@"opponentsIDs"] != nil) {
        NSString *opponentsIDsString = (NSString *)payload.dictionaryPayload[@"opponentsIDs"];
        NSArray *opponentsIDsArray = [opponentsIDsString componentsSeparatedByString:@","];
        if (opponentsIDsArray.count == 2) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *timeStampString = payload.dictionaryPayload[@"timestamp"];
            NSDate *startCallDate = [formatter dateFromString:timeStampString];
            NSTimeInterval timeIntervalSinceStartCall = [[NSDate date] timeIntervalSinceDate:startCallDate];
            if (timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval) {
                Log(@"[%@] timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval",  NSStringFromClass([UsersViewController class]));
                return;
            }
        }
    }
    
    if (type == PKPushTypeVoIP &&
        [payload.dictionaryPayload objectForKey:kVoipEvent] != nil &&
        [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        __weak __typeof(self)weakSelf = self;
        
        NSMutableArray<NSNumber *> *opponentsNumberIDs = [NSMutableArray array];
        NSArray<NSString *> *opponentsIDs = nil;
        NSString *opponentsNamesString = @"incoming call. Connecting...";
        NSString *sessionID = nil;
        NSUUID *callUUID = [NSUUID UUID];
        NSUInteger sessionConferenceType = QBRTCConferenceTypeAudio;
        self.isUpdatedPayload = NO;
        [QBRTCClient.instance addDelegate:self];
        
        // updated payload
        if (payload.dictionaryPayload[@"opponentsIDs"] != nil
            && payload.dictionaryPayload[@"contactIdentifier"] != nil
            && payload.dictionaryPayload[@"sessionID"] != nil) {
            self.isUpdatedPayload = YES;
            NSString *opponentsIDsString = (NSString *)payload.dictionaryPayload[@"opponentsIDs"];
            NSString *allOpponentsNamesString = (NSString *)payload.dictionaryPayload[@"contactIdentifier"];
            NSString *sessionIDString = (NSString *)payload.dictionaryPayload[@"sessionID"];
            sessionID = sessionIDString;
            NSString *conferenceTypeString = (NSString *)payload.dictionaryPayload[@"conferenceType"];
            sessionConferenceType = [conferenceTypeString isEqualToString:@"1"] ? QBRTCConferenceTypeVideo : QBRTCConferenceTypeAudio;
            callUUID = [[NSUUID alloc] initWithUUIDString:sessionIDString];
            Profile *currentUser = [[Profile alloc] init];
            if (currentUser.isFull == NO) {
                return;
            }
            
            NSArray *opponentsIDsArray = [opponentsIDsString componentsSeparatedByString:@","];
            
            __block NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            [opponentsIDsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *userID = (NSString *)obj;
                NSInteger ID = userID.integerValue;
                [tmpArray addObject:@(ID)];
            }];
            NSMutableArray<NSNumber *> *opponentsNumberIDsArray = tmpArray;
            NSMutableArray *allOpponentsNamesArray = [NSMutableArray arrayWithArray:[allOpponentsNamesString componentsSeparatedByString:@","]];
            
            for (int i = 0; i < opponentsNumberIDsArray.count; i++) {
                if (opponentsNumberIDsArray[i].integerValue == currentUser.ID) {
                    [opponentsNumberIDsArray removeObjectAtIndex:i];
                    [allOpponentsNamesArray removeObjectAtIndex:i];
                    break;
                }
            }
            opponentsNumberIDs = opponentsNumberIDsArray;

            __block NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [opponentsNumberIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSNumber *userID = (NSNumber *)obj;
                [tempArray addObject:userID.stringValue];
            }];
            opponentsIDs = tempArray.copy;
            opponentsNamesString = [allOpponentsNamesArray componentsJoinedByString:@", "];
        }
        
        void(^fetchUsersCompletion)( NSArray<NSString *> * _Nullable) = ^(NSArray<NSString *> * _Nullable opponentsIDs) {
            if (opponentsIDs) {
                [QBRequest usersWithIDs:opponentsIDs page:nil successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
                    [weakSelf.dataSource updateUsers:users];
                } errorBlock:^(QBResponse * _Nonnull response) {
                    Log(@"[%@] error fetch usersWithIDs",  NSStringFromClass([UsersViewController class]));
                }];
            }
        };
        
        if (![QBChat instance].isConnected) {
            [weakSelf connectToChatWithSuccessCompletion:^(NSError * _Nullable error) {
                if (!error) {
                    if (fetchUsersCompletion) {
                        fetchUsersCompletion(opponentsIDs);
                    }
                }
            }];
        } else {
            if (fetchUsersCompletion) {
                fetchUsersCompletion(opponentsIDs);
            }
        }
        
        [self setupAnswerTimerWithTimeInterval:60.0f];
        
        [CallKitManager.instance reportIncomingCallWithUserIDs:opponentsNumberIDs outCallerName:opponentsNamesString session:nil sessionID:sessionID sessionConferenceType:sessionConferenceType uuid:callUUID onAcceptAction:^(Boolean isAccept) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            
            if (self.session) {
                if (isAccept == YES) {
                    [strongSelf openCallWithSession:self.session uuid:callUUID sessionConferenceType:self.session.conferenceType];
                    Log(@"[%@] onAcceptAction",  NSStringFromClass([UsersViewController class]));
                } else {
                    [self.session rejectCall:@{@"reject" : @"busy"}];
                }
            } else {
                if (isAccept == YES) {
                    [strongSelf openCallWithSession:nil uuid:callUUID sessionConferenceType:sessionConferenceType];
                    Log(@"[%@] onAcceptAction without session",  NSStringFromClass([UsersViewController class]));
                    
                } else {
                    Log(@"[%@] endCallAction",  NSStringFromClass([UsersViewController class]));
                }
                [strongSelf prepareBackgroundTask];
                [strongSelf setupAnswerTimerWithTimeInterval:kAnswerInterval];
            }
            
            completion();
        } completion:^(BOOL isOpen) {
            __weak __typeof(self)weakSelf = self;
            [weakSelf prepareBackgroundTask];
            [weakSelf setupAnswerTimerWithTimeInterval:60.0f];
            Log(@"[%@] callKit did presented",  NSStringFromClass([UsersViewController class]));
        }];
    }
}

- (void)prepareBackgroundTask {
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        && _backgroundTask == UIBackgroundTaskInvalid) {
        _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)connectToChatWithSuccessCompletion:(QBChatCompletionBlock)success;  {
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    [QBChat.instance connectWithUserID:currentUser.ID
                              password:DEFAULT_PASSOWORD
                            completion:^(NSError * _Nullable error) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error) {
            if (error.code == QBResponseStatusCodeUnAuthorized) {
                [strongSelf logoutAction];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Please check your Internet connection", nil)];
                
            }
            if (success) {
                success(error);
            }
        } else {
            if (success) {
                success(nil);
            }
            [SVProgressHUD dismiss];
        }
    }];
}

@end
