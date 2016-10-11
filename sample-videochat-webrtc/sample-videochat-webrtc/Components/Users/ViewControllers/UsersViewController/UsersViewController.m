//
//  UsersViewController.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UsersViewController.h"
#import <Quickblox/Quickblox.h>

#import "QBCore.h"
#import "UsersDataSource.h"
#import "PlaceholderGenerator.h"
#import "QBAVCallPermissions.h"
#import "SessionSettingsViewController.h"
#import "SVProgressHUD.h"
#import "CallViewController.h"
#import "IncomingCallViewController.h"

const NSUInteger kQBPageSize = 50;

@interface UsersViewController () <QBCoreDelegate, QBRTCClientDelegate, SettingsViewControllerDelegate, IncomingCallViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *audioCallButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *videoCallButton;

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *session;

@end

@implementation UsersViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}
/**
 *  Load all (Recursive) users for current room (tag)
 */
- (void)loadUsers {
    
    __block void(^t_request) (QBGeneralResponsePage *, NSMutableArray *);
    __weak __typeof(self)weakSelf = self;
    
    void(^request) (QBGeneralResponsePage *, NSMutableArray *) =
    ^(QBGeneralResponsePage *page, NSMutableArray *allUsers) {
        
        [QBRequest usersWithTags:@[@"chatRoom", @"chats"]
                            page:page
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBUUser *> *users)
         {
             page.currentPage++;
             [allUsers addObjectsFromArray:users];
             
             BOOL cancel;
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
    } ;
    
    t_request = [request copy];
    
    QBGeneralResponsePage *responsePage =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:kQBPageSize];
    NSMutableArray *allUsers = [NSMutableArray array];
    
    request(responsePage, allUsers);
}

#pragma mark - Actions

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
                    CallViewController *callViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
                    callViewController.session = self.session;
                    callViewController.usersDatasource = self.dataSource;
                    
                    self.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
                    self.nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    
                    [self presentViewController:self.nav animated:NO completion:nil];
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
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logout...", nil)];
    [Core logout];
}

#pragma mark - UITableViewDelegate

const NSUInteger kMaxUsersToCall = 5;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource selectUserAtIndexPath:indexPath];
    
    [self setToolbarButtonsEnabled:self.dataSource.selectedUsers.count > 0];
    
    if (self.dataSource.selectedUsers.count > 4) {
        self.videoCallButton.enabled = NO;
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - QBSampleCoreDelegate

- (void)coreDidLogout:(QBCore *)core {
    
    [SVProgressHUD dismiss];
    //Dismiss Settings view controller
    [self dismissViewControllerAnimated:NO completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:NO];
    });
}

- (void)core:(QBCore *)core error:(NSError *)error domain:(ErrorDomain)domain {
    
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
    
    if (self.session ) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.session = session;
    
    [QBRTCSoundRouter.instance initialize];
    
    NSParameterAssert(!self.nav);
    
    IncomingCallViewController *incomingViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
    incomingViewController.delegate = self;
    incomingViewController.session = session;
    incomingViewController.usersDatasource = self.dataSource;
    
    self.nav = [[UINavigationController alloc] initWithRootViewController:incomingViewController];
    [self presentViewController:self.nav animated:NO completion:nil];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session ) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.nav.view.userInteractionEnabled = NO;
            [self.nav dismissViewControllerAnimated:NO completion:nil];
            self.session = nil;
            self.nav = nil;
        });
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

@end
