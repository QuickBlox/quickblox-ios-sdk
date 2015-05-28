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

-(void)reachabilityChanged:(NSNotification*)note;
@property (strong, nonatomic) UsersDataSource *dataSource;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;
@end

@implementation LoginTableViewController

NSString *const kGoToDialogsSegueIdentifier = @"goToDialogs";

- (void)viewDidLoad {
	[super viewDidLoad];
	self.dataSource = [[UsersDataSource alloc] init];
	self.tableView.dataSource = self.dataSource;
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
	
	[QBServicesManager.instance.usersService usersWithSuccessBlock:^(NSArray *users) {
		[weakSelf.tableView reloadData];
		
		[SVProgressHUD showSuccessWithStatus:@"Completed"];
		weakSelf.usersAreDownloading = NO;
	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:@"Can not download users"];
		weakSelf.usersAreDownloading = NO;
	}];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
	
	QBUUser *selectedUser = StorageManager.instance.users[indexPath.row];
	
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
		[self downloadUsers];
	}
}


@end
