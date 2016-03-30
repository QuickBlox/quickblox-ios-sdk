//
//  OutgoingCallViewControllerWithTagViewController.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/14/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "OutgoingCallViewControllerWithTagViewController.h"
#import "SVProgressHUD.h"
#import "SampleCore.h"
#import "SampleCoreManager.h"

@interface OutgoingCallViewControllerWithTagViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation OutgoingCallViewControllerWithTagViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self addRefreshControl];
}

- (void)addRefreshControl {
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(reloadUsers:) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];
}

- (void)reloadUsers:(id)sender {
	__weak __typeof(self)weakSelf = self;
	
	[self.refreshControl beginRefreshing];
	
	[SampleCoreManager allUsersWithTags:[[SampleCore usersDataSource] tags] perPageLimit:50 successBlock:^(NSArray *usersObjects) {

		[[SampleCore usersDataSource] loadUsersWithArray:usersObjects tags:[SampleCore usersDataSource].tags];
		[SVProgressHUD showSuccessWithStatus:@"Reloaded!"];

		[weakSelf.refreshControl endRefreshing];
		[weakSelf.tableView reloadData];

	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error: %@", response.error.reasons.description]];
		[weakSelf.refreshControl endRefreshing];
	}];
}

- (IBAction)logOut:(id)sender {
	[self accountLogout];
}

@end
