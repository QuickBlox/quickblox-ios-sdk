//
//  UsersViewController.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UsersViewController.h"

#import <Quickblox/Quickblox.h>
#import <PushKit/PushKit.h>

#import "QBCore.h"
#import "UsersDataSource.h"
#import "PlaceholderGenerator.h"
#import "QBAVCallPermissions.h"
#import "SessionSettingsViewController.h"
#import "SVProgressHUD.h"
#import "CallViewController.h"
#import "IncomingCallViewController.h"
#import "RecordsViewController.h"
#import "CallKitManager.h"

const NSUInteger kQBPageSize = 50;
static NSString * const kAps = @"aps";
static NSString * const kAlert = @"alert";
static NSString * const kVoipEvent = @"VOIPCall";

@interface UsersViewController () <QBCoreDelegate, QBRTCClientDelegate, SettingsViewControllerDelegate, IncomingCallViewControllerDelegate, PKPushRegistryDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *audioCallButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *videoCallButton;

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) RecordsViewController *recordsViewController;

@property (strong, nonatomic) PKPushRegistry *voipRegistry;

@property (strong, nonatomic) NSUUID *callUUID;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation UsersViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backgroundTask = UIBackgroundTaskInvalid;
    
    [Core addDelegate:self];
    [QBRTCClient.instance addDelegate:self];
    // Reachability
    __weak __typeof(self)weakSelf = self;
    Core.networkStatusBlock = ^(QBNetworkStatus status) {
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
    
    if (self.refreshControl.refreshing) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - UI Configuration

- (void)configureTableViewController {
    
    _dataSource = [[UsersDataSource alloc] initWithCurrentUser:Core.currentUser];
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
    NSString *roomName = [NSString stringWithFormat:@"%@", Core.currentUser.tags.firstObject];
    NSString *userName = [NSString stringWithFormat:@"Logged in as %@", Core.currentUser.fullName];
    NSString *titleString = [NSString stringWithFormat:@"%@\n%@", roomName, userName];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSRange roomNameRange = [titleString rangeOfString:roomName];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:16.0f]
                       range:roomNameRange];
    
    NSRange userNameRange = [titleString rangeOfString:userName];
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
    
    UIBarButtonItem *recordsButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Records"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didPressRecordsButton:)];
    
    self.navigationItem.rightBarButtonItem = recordsButtonItem;
}
/**
 *  Load all (Recursive) users for current room (tag)
 */
- (void)loadUsers {
    
    __block void(^t_request) (QBGeneralResponsePage *, NSMutableArray *);
    __weak __typeof(self)weakSelf = self;
    
    void(^request) (QBGeneralResponsePage *, NSMutableArray *) =
    ^(QBGeneralResponsePage *page, NSMutableArray *allUsers) {
        
        [QBRequest usersWithTags:Core.currentUser.tags
                            page:page
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBUUser *> *users)
         {
             page.currentPage++;
             [allUsers addObjectsFromArray:users];
             
             BOOL cancel = NO;
             if (page.currentPage * page.perPage >= page.totalEntries) {
                 cancel = YES;
             }
             
             if (!cancel) {
                 t_request(page, allUsers);
             }
             else {
                 [weakSelf.refreshControl endRefreshing];
                 BOOL isUpdated = [weakSelf.dataSource setUsers:allUsers];
                 if (isUpdated) {
                     [weakSelf.tableView reloadData];
                 }
                 t_request = nil;
             }
             
         } errorBlock:^(QBResponse *response) {
             [weakSelf.refreshControl endRefreshing];
             t_request = nil;
         }];
    };
    
    t_request = [request copy];
    
    QBGeneralResponsePage *responsePage =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:kQBPageSize];
    NSMutableArray *allUsers = [NSMutableArray array];
    
    request(responsePage, allUsers);
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
    
    if ([self hasConnectivity]) {
        
        [QBAVCallPermissions checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
            
            if (granted) {
                
                NSArray *opponentsIDs = [self.dataSource idsForUsers:self.dataSource.selectedUsers];
                //Create new session
                QBRTCSession *session =
                [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                                 withConferenceType:conferenceType];
                if (session) {
                    
                    self.session = session;
                    
                    NSUUID *uuid = nil;
                    if (CallKitManager.isCallKitAvailable) {
                        uuid = [NSUUID UUID];
                        [CallKitManager.instance startCallWithUserIDs:opponentsIDs session:session uuid:uuid];
                    }
                    
                    CallViewController *callViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
                    callViewController.session = self.session;
                    callViewController.usersDatasource = self.dataSource;
                    callViewController.callUUID = uuid;
                    
                    self.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
                    self.nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    
                    [self presentViewController:self.nav animated:NO completion:nil];
                    
                    NSDictionary *payload = @{
                                              @"message"  : [NSString stringWithFormat:@"%@ is calling you.", Core.currentUser.fullName],
                                              @"ios_voip" : @"1",
                                              kVoipEvent  : @"1",
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
                    event.usersIDs = [opponentsIDs componentsJoinedByString:@","];
                    event.type = QBMEventTypeOneShot;
                    event.message = message;
                    
                    [QBRequest createEvent:event
                              successBlock:^(QBResponse *response, NSArray<QBMEvent *> *events) {
                                  NSLog(@"Send voip push - Success");
                              } errorBlock:^(QBResponse * _Nonnull response) {
                                  NSLog(@"Send voip push - Error");
                              }];
                }
                else {
                    
                    [SVProgressHUD showErrorWithStatus:@"You should login to use chat API. Session hasn’t been created. Please try to relogin the chat."];
                }
            }
        }];
    }
}

- (BOOL)hasConnectivity {
    
    BOOL hasConnectivity = Core.networkStatus != QBNetworkStatusNotReachable;
    
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
    
    [self performSegueWithIdentifier:@"PresentSettingsViewController" sender:item];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentSettingsViewController"]) {
        
        SessionSettingsViewController *settingsViewController =
        (id)((UINavigationController *)segue.destinationViewController).topViewController;
        settingsViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"PresentRecordsViewController"]) {
        self.recordsViewController = segue.destinationViewController;
    }
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logout...", nil)];
    [Core logout];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource selectUserAtIndexPath:indexPath];
    
    [self setToolbarButtonsEnabled:self.dataSource.selectedUsers.count > 0];
    
    if (self.dataSource.selectedUsers.count > 4) {
        self.videoCallButton.enabled = NO;
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - QBSampleCoreDelegate

- (void)core:(QBCore *)core loginStatus:(NSString *)loginStatus {
    [SVProgressHUD showWithStatus:loginStatus];
}

- (void)coreDidLogin:(QBCore *)core {
    [SVProgressHUD dismiss];
}

- (void)coreDidLogout:(QBCore *)core {
    [SVProgressHUD dismiss];
    //Dismiss Settings view controller
    [self dismissViewControllerAnimated:NO completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:NO];
    });
}

- (void)core:(QBCore *)core error:(NSError *)error domain:(ErrorDomain)domain {
    [SVProgressHUD dismiss];
    if (domain == ErrorDomainLogOut) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
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

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    
    if (self.session != nil
        || self.recordsViewController.playerPresented) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.session = session;
    
    if (CallKitManager.isCallKitAvailable) {
        self.callUUID = [NSUUID UUID];
        NSMutableArray *opponentIDs = [@[session.initiatorID] mutableCopy];
        for (NSNumber *userID in session.opponentsIDs) {
            if ([userID integerValue] != [QBCore instance].currentUser.ID) {
                [opponentIDs addObject:userID];
            }
        }
        __weak __typeof(self)weakSelf = self;
        [CallKitManager.instance reportIncomingCallWithUserIDs:[opponentIDs copy] session:session uuid:self.callUUID onAcceptAction:^{
            __typeof(weakSelf)strongSelf = weakSelf;
            CallViewController *callViewController =
            [strongSelf.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
            
            callViewController.session = session;
            callViewController.usersDatasource = strongSelf.dataSource;
            callViewController.callUUID = self.callUUID;
            strongSelf.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
            [strongSelf presentViewController:strongSelf.nav animated:NO completion:nil];
            
        } completion:nil];
    }
    else {
        
        NSParameterAssert(!self.nav);
        
        IncomingCallViewController *incomingViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
        incomingViewController.delegate = self;
        incomingViewController.session = session;
        incomingViewController.usersDatasource = self.dataSource;
        
        self.nav = [[UINavigationController alloc] initWithRootViewController:incomingViewController];
        [self presentViewController:self.nav animated:NO completion:nil];
    }
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session) {
        if (_backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground
                && _backgroundTask == UIBackgroundTaskInvalid) {
                // dispatching chat disconnect in 1 second so message about call end
                // from webrtc does not cut mid sending
                // checking for background task being invalid though, to avoid disconnecting
                // from chat when another call has already being received in background
                [QBChat.instance disconnectWithCompletionBlock:nil];
            }
        });
        
        if (self.nav != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.nav.view.userInteractionEnabled = NO;
                [self.nav dismissViewControllerAnimated:NO completion:nil];
                self.session = nil;
                self.nav = nil;
            });
        }
        else if (CallKitManager.isCallKitAvailable) {
            [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
            self.callUUID = nil;
            self.session = nil;
        }
    }
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didAcceptSession:(QBRTCSession *)session {
    
    CallViewController *callViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    callViewController.session = session;
    callViewController.usersDatasource = self.dataSource;
    self.nav.viewControllers = @[callViewController];
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didRejectSession:(QBRTCSession *)session {
    
    [session rejectCall:nil];
    [self.nav dismissViewControllerAnimated:NO completion:nil];
    self.nav = nil;
}

// MARK: - PKPushRegistryDelegate protocol

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    
    //  New way, only for updated backend
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = [self.voipRegistry pushTokenForType:PKPushTypeVoIP];
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Create Subscription request - Success");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Create Subscription request - Error");
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Unregister Subscription request - Success");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"Unregister Subscription request - Error");
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    if (CallKitManager.isCallKitAvailable) {
        if ([payload.dictionaryPayload objectForKey:kVoipEvent] != nil) {
            UIApplication *application = [UIApplication sharedApplication];
            if (application.applicationState == UIApplicationStateBackground
                && _backgroundTask == UIBackgroundTaskInvalid) {
                _backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                    [application endBackgroundTask:_backgroundTask];
                    _backgroundTask = UIBackgroundTaskInvalid;
                }];
            }
            if (![QBChat instance].isConnected) {
                [[QBCore instance] loginWithCurrentUser];
            }
        }
    }
}

@end
