//
//  LoginTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "LoginTableViewController.h"
#import "UsersDataSource.h"
#import "ConnectionManager.h"
#import "UserTableViewCell.h"

@interface LoginTableViewController ()
@property (nonatomic, strong) NSArray *users;
@end

@implementation LoginTableViewController
NSString *const kUserTableViewCellIdentifier = @"UserTableViewCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	__weak __typeof(self)weakSelf = self;
	[ConnectionManager.instance usersWithSuccessBlock:^(NSArray *users) {
		weakSelf.users = users;
		[weakSelf.tableView reloadData];
	} errorBlock:^(QBResponse *response) {
		
	}];
}


#pragma mark - Table view data source

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
