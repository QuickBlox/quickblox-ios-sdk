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

/*
 * Default test users password
 */
static NSString * const kTestUsersDefaultPassword = @"x6Bt0VDy5";

- (void)viewDidLoad {
	[super viewDidLoad];
    
    NSString *versionString = [NSString stringWithFormat:@"%@", [self versionBuild]];
    self.buildNumberLabel.text = versionString;
    
	ServicesManager *servicesManager = [ServicesManager instance];
	
    if (servicesManager.currentUser != nil) {
        // loggin in with previous user
        servicesManager.currentUser.password = kTestUsersDefaultPassword;
        [SVProgressHUD showWithStatus:[NSLocalizedString(@"SA_STR_LOGGING_IN_AS", nil) stringByAppendingString:servicesManager.currentUser.login] maskType:SVProgressHUDMaskTypeClear];
        
        __weak __typeof(self)weakSelf = self;
        [servicesManager logInWithUser:servicesManager.currentUser completion:^(BOOL success, NSString *errorMessage) {
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
	__weak __typeof(self)weakSelf = self;
    
    // Retrieving users from cache.
    [[[ServicesManager instance].usersService loadFromCache] continueWithBlock:^id(BFTask *task) {
        //
        if ([task.result count] > 0) {
            [weakSelf loadDataSourceWithUsers:[[ServicesManager instance] sortedUsers]];
        } else {
            [weakSelf downloadCurrentEnvironmentUsers];
        }
        
        return nil;
    }];
}

- (void)downloadCurrentEnvironmentUsers {
	if (self.isUsersAreDownloading) return;
    
	self.usersAreDownloading = YES;
	
	__weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_USERS", nil) maskType:SVProgressHUDMaskTypeClear];
	
    // Downloading latest users.
	[[ServicesManager instance] downloadCurrentEnvironmentUsersWithSuccessBlock:^(NSArray *latestUsers) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SA_STR_COMPLETED", nil)];
        [weakSelf loadDataSourceWithUsers:latestUsers];
        weakSelf.usersAreDownloading = NO;
	} errorBlock:^(NSError *error) {
		[SVProgressHUD showErrorWithStatus:error.localizedDescription];
		weakSelf.usersAreDownloading = NO;
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
    
    self.navigationController.viewControllers = @[dialogsController, chatController];
}

- (void)notificationServiceDidFailFetchingDialog {
	// TODO: maybe segue class should be ReplaceSegue?
    [self performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
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
	
	QBUUser *selectedUser = self.dataSource.users[indexPath.row];
	selectedUser.password = kTestUsersDefaultPassword;
	
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
