//
//  EditDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "EditDialogTableViewController.h"
#import "UsersDataSource.h"
#import "QBServicesManager.h"

@interface EditDialogTableViewController()
@property (nonatomic, strong) UsersDataSource *dataSource;
@end

@implementation EditDialogTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	__weak __typeof(self) weakSelf = self;
	[QBServicesManager.instance.usersService retrieveUsersWithIDs:self.dialog.occupantIDs completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
		weakSelf.dataSource = [[UsersDataSource alloc] initWithUsers:users];
		weakSelf.tableView.dataSource = weakSelf.dataSource;
		[weakSelf.tableView reloadData];
	}];

}

- (SWTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SWTableViewCell *cell = (SWTableViewCell *) [super.tableView cellForRowAtIndexPath:indexPath];
	
	QBUUser *user = ((UsersDataSource *)self.tableView.dataSource).users[indexPath.row];
	
	
	
	return cell;
}

@end
