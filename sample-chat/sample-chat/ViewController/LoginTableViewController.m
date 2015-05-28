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

@interface LoginTableViewController ()
@property (nonatomic, strong) NSArray *users;
@end

@implementation LoginTableViewController
NSString *const kUserTableViewCellIdentifier = @"UserTableViewCellIdentifier";
NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self downloadUsers];
}

- (void)downloadUsers {
	__weak __typeof(self)weakSelf = self;
	[SVProgressHUD showWithStatus:@"Loading users" maskType:SVProgressHUDMaskTypeClear];
	
	[QBServiceManager.instance.usersService usersWithSuccessBlock:^(NSArray *users) {
		weakSelf.users = users;
		[weakSelf.tableView reloadData];
		
		[SVProgressHUD showSuccessWithStatus:@"Completed"];
	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:@"Can not download users, trying again in 5 seconds"];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[weakSelf downloadUsers];
		});
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

@end
