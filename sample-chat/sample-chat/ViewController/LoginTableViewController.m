//
//  LoginTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "LoginTableViewController.h"
#import "StorageManager.h"
#import "QBServicesManager.h"
#import "ReachabilityManager.h"
#import "Reachability.h"
#import "StorageManager.h"
#import "UsersDataSource.h"

@interface LoginTableViewController ()

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;

@end

@implementation LoginTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self retrieveUsers];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)retrieveUsers
{
	__weak __typeof(self)weakSelf = self;

	[QBServicesManager.instance.usersService cachedUsersWithCompletion:^(NSArray *users) {
		if (users != nil && users.count != 0) {
			[weakSelf loadDataSourceWithUsers:users];
		}
		[weakSelf downloadLatestUsers];
	}];
}

- (void)downloadLatestUsers
{
	if (self.isUsersAreDownloading) return;
    
	self.usersAreDownloading = YES;
	
	__weak __typeof(self)weakSelf = self;
	if (self.dataSource == nil) {
		[SVProgressHUD showWithStatus:@"Loading users" maskType:SVProgressHUDMaskTypeClear];
	}
	
	[QBServicesManager.instance.usersService downloadLatestUsersWithSuccessBlock:^(NSArray *latestUsers) {
		if (weakSelf.dataSource == nil) {
			[SVProgressHUD showSuccessWithStatus:@"Completed"];
			[weakSelf loadDataSourceWithUsers:latestUsers];
		} else {
			[weakSelf.dataSource addUsers:latestUsers];
			[weakSelf.tableView reloadData];
		}
		
		weakSelf.usersAreDownloading = NO;
	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:@"Can not download users"];
		weakSelf.usersAreDownloading = NO;
	}];
}

- (void)loadDataSourceWithUsers:(NSArray *)users
{
	self.dataSource = [[UsersDataSource alloc] initWithUsers:users];
	self.tableView.dataSource = self.dataSource;
	[self.tableView reloadData];
}
#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
	
	QBUUser *selectedUser = StorageManager.instance.users[indexPath.row];
	selectedUser.password = @"x6Bt0VDy5"; // default password for test users
	
	__weak __typeof(self)weakSelf = self;
	
	[QBServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
		if( success ) {
			[SVProgressHUD showSuccessWithStatus:@"Logged in"];
			[weakSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
		}
		else {
			[SVProgressHUD showErrorWithStatus:@"Can not login"];
		}
	}];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Reachability notifications

- (void)reachabilityChanged:(NSNotification *)note {
	ReachabilityManager *reach = [ReachabilityManager instance];
	
	if( reach.isReachable && StorageManager.instance.users == nil){
		[self downloadLatestUsers];
	}
}


@end
