//
//  LoginTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "LoginTableViewController.h"
#import "StorageManager.h"
#import "ConnectionManager.h"
#import "UserTableViewCell.h"
#import "QBServiceManager.h"
#import "ReachabilityManager.h"
#import "Reachability.h"

@interface LoginTableViewController ()

@property (nonatomic, strong) NSArray *users;
-(void)reachabilityChanged:(NSNotification*)note;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;
@end

@implementation LoginTableViewController

NSString *const kUserTableViewCellIdentifier = @"UserTableViewCellIdentifier";
NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	
	[self downloadUsers];
}

- (void)downloadUsers {
	if( self.isUsersAreDownloading ){
		return;
	}
	self.usersAreDownloading = YES;
	
	__weak __typeof(self)weakSelf = self;
	[SVProgressHUD showWithStatus:@"Loading users" maskType:SVProgressHUDMaskTypeClear];
	
	[QBServiceManager.instance.usersService usersWithSuccessBlock:^(NSArray *users) {
		weakSelf.users = users;
		[weakSelf.tableView reloadData];
		
		[SVProgressHUD showSuccessWithStatus:@"Completed"];
		self.usersAreDownloading = NO;
	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:@"Can not download users"];
		self.usersAreDownloading = NO;
	}];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
	
	QBUUser *selectedUser = StorageManager.instance.users[indexPath.row];
	
	__weak __typeof(self)weakSelf = self;
	[ConnectionManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserTableViewCellIdentifier forIndexPath:indexPath];
	
	QBUUser *user = (QBUUser *)self.users[indexPath.row];
	
	cell.userDescription = user.fullName;
	[cell setColorMarkerText:[NSString stringWithFormat:@"%zd", indexPath.row+1] andColor:user.color];
	return cell;
}

#pragma mark - Reachability notifications

- (void)reachabilityChanged:(NSNotification *)note {
	ReachabilityManager *reach = [ReachabilityManager instance];
	
	if( reach.isReachable && self.users == nil){
		[self downloadUsers];
	}
	
}


@end
