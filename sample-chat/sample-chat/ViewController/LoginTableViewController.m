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

@interface LoginTableViewController ()

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;

@end

@implementation LoginTableViewController

/*
 *  Default test users password
 */
static NSString *const kTestUsersDefaultPassword = @"x6Bt0VDy5";

- (void)viewDidLoad
{
	[super viewDidLoad];
    if (ServicesManager.instance.currentUser != nil) {
        // loggin in with previous user
        ServicesManager.instance.currentUser.password = kTestUsersDefaultPassword;
        [SVProgressHUD showWithStatus:[@"Logging in as " stringByAppendingString:ServicesManager.instance.currentUser.login] maskType:SVProgressHUDMaskTypeClear];
        
        __weak __typeof(self)weakSelf = self;
        [ServicesManager.instance logInWithUser:ServicesManager.instance.currentUser completion:^(BOOL success, NSString *errorMessage) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"Logged in"];
                __typeof(self) strongSelf = weakSelf;
                [strongSelf registerForRemoteNotifications];
                
                BOOL appLaunchedFromPush = [(AppDelegate *)[[UIApplication sharedApplication] delegate] appLaunchedFromPush];
                if (!appLaunchedFromPush) {
                    [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
                }
                else {
                    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setAppLaunchedFromPush:NO];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:@"Can not login"];
            }
        }];
    }

    [self retrieveUsers];
}

- (void)retrieveUsers
{
	__weak __typeof(self)weakSelf = self;
    
    // Retrieving users from cache.
	[ServicesManager.instance.usersService cachedUsersWithCompletion:^(NSArray *users) {
		if (users != nil && users.count != 0) {
			[weakSelf loadDataSourceWithUsers:users];
        } else {
            [weakSelf downloadLatestUsers];
        }
	}];
}

- (void)downloadLatestUsers
{
	if (self.isUsersAreDownloading) return;
    
	self.usersAreDownloading = YES;
	
	__weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"Loading users" maskType:SVProgressHUDMaskTypeClear];
	
    // Downloading latest users.
	[ServicesManager.instance.usersService downloadLatestUsersWithSuccessBlock:^(NSArray *latestUsers) {
        [SVProgressHUD showSuccessWithStatus:@"Completed"];
        [weakSelf loadDataSourceWithUsers:latestUsers];
        weakSelf.usersAreDownloading = NO;
	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:@"Can not download users"];
		weakSelf.usersAreDownloading = NO;
	}];
}

- (void)loadDataSourceWithUsers:(NSArray *)users
{
	self.dataSource = [[UsersDataSource alloc] initWithUsers:users];
    self.dataSource.isLoginDataSource = YES;
	self.tableView.dataSource = self.dataSource;
	[self.tableView reloadData];
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeClear];
	
	QBUUser *selectedUser = self.dataSource.users[indexPath.row];
	selectedUser.password = kTestUsersDefaultPassword;
	
	__weak __typeof(self)weakSelf = self;
    // Logging in to Quickblox REST API and chat.
    [ServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Logged in"];
            [weakSelf registerForRemoteNotifications];
            __typeof(self) strongSelf = weakSelf;
            [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Can not login"];
        }
    }];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)backToLoginViewController:(UIStoryboardSegue *)segue
{

}

@end
