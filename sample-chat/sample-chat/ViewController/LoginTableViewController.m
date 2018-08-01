//
//  LoginTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "LoginTableViewController.h"
#import "ServicesManager.h"
#import "UsersDataSource.h"
#import "AppDelegate.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"

@interface LoginTableViewController () <NotificationServiceDelegate>

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;
@property (weak, nonatomic) IBOutlet UILabel *buildNumberLabel;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIApplication sharedApplication].keyWindow.tintColor;
    [self.refreshControl addTarget:self
                            action:@selector(downloadCurrentEnvironmentUsers)
                  forControlEvents:UIControlEventValueChanged];
    
    NSString *versionString = [NSString stringWithFormat:@"%@", [self versionBuild]];
    self.buildNumberLabel.text = versionString;
    
    ServicesManager *servicesManager = [ServicesManager instance];
    QBUUser *currentUser = servicesManager.currentUser;
    
    if (currentUser != nil) {
        // loggin in with previous user
        currentUser.password = currentUser.login;
        
        NSString *userName = currentUser.login.length ? currentUser.login : @"test_user_id1";
        
        [SVProgressHUD showWithStatus:[NSLocalizedString(@"SA_STR_LOGGING_IN_AS", nil) stringByAppendingString:userName] maskType:SVProgressHUDMaskTypeClear];
        
        __weak __typeof(self)weakSelf = self;
        [servicesManager logInWithUser:currentUser completion:^(BOOL success, NSString *errorMessage) {
            if (success) {
                __typeof(self) strongSelf = weakSelf;
                [strongSelf registerForRemoteNotifications];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
                
                if (servicesManager.notificationService.pushDialogID == nil) {
                    [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
                }
                else {
                    [servicesManager.notificationService handlePushNotificationWithDelegate:self];
                }
                
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_ERROR", nil)];
            }
        }];
    }
    
    [self retrieveUsers];
}

/**
 *  Retrieve users from cache or download them from REST
 */
- (void)retrieveUsers {
    
    if ([ServicesManager instance].usersService.usersMemoryStorage.unsortedUsers.count > 0) {
        [self loadDataSourceWithUsers:[[ServicesManager instance] sortedUsers]];
    } else {
        [self downloadCurrentEnvironmentUsers];
    }
}

- (void)downloadCurrentEnvironmentUsers {
    
    if (self.isUsersAreDownloading) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.usersAreDownloading = YES;
    
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_USERS", nil) maskType:SVProgressHUDMaskTypeClear];
    
    // Downloading latest users.
    [[ServicesManager instance] downloadCurrentEnvironmentUsersWithSuccessBlock:^(NSArray *latestUsers) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
        [weakSelf loadDataSourceWithUsers:latestUsers];
        weakSelf.usersAreDownloading = NO;
        [weakSelf.refreshControl endRefreshing];
        
    } errorBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        weakSelf.usersAreDownloading = NO;
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (void)loadDataSourceWithUsers:(NSArray *)users {
    
    self.dataSource = [[UsersDataSource alloc] initWithUsers:users];
    self.dataSource.addStringLoginAsBeforeUserFullname = YES;
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}

#pragma mark - NotificationServiceDelegate protocol

- (void)notificationServiceDidStartLoadingDialogFromServer {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_DIALOG", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)notificationServiceDidFinishLoadingDialogFromServer {
    [SVProgressHUD dismiss];
}

- (void)notificationServiceDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    DialogsViewController *dialogsController = (DialogsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    ChatViewController *chatController = (ChatViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.dialog = chatDialog;
    
    NSMutableArray * viewControllers = self.navigationController.viewControllers.mutableCopy;
    [viewControllers addObjectsFromArray:@[dialogsController,chatController]];
    
    self.navigationController.viewControllers = viewControllers;
    
}

- (void)notificationServiceDidFailFetchingDialog {
    // TODO: maybe segue class should be ReplaceSegue?
    [self performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications{
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *selectedUser = self.dataSource.users[indexPath.row];
    selectedUser.password = selectedUser.login;
    
    [SVProgressHUD showWithStatus:[NSLocalizedString(@"SA_STR_LOGGING_IN_AS", nil) stringByAppendingString:selectedUser.login] maskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    // Logging in to Quickblox REST API and chat.
    [ServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            __typeof(self) strongSelf = weakSelf;
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_LOGGED_IN", nil)];
            [strongSelf registerForRemoteNotifications];
            [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)backToLoginViewController:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Private

- (NSString *)versionBuild {
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *versionBuild = [NSString stringWithFormat: @"v%@", version];
    
    if (![version isEqualToString:build]) {
        
        versionBuild = [NSString stringWithFormat:@"%@(%@)", versionBuild, build];
    }
    
    return versionBuild;
}

@end
