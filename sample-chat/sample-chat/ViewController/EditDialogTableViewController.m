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
	NSParameterAssert(self.dialog);
	self.dataSource = [[UsersDataSource alloc] init];
	[self.dataSource setExcludeUsersIDs:self.dialog.occupantIDs];
	self.tableView.dataSource = self.dataSource;
	[self.tableView reloadData];

}

- (SWTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SWTableViewCell *cell = (SWTableViewCell *) [super.tableView cellForRowAtIndexPath:indexPath];
	
	QBUUser *user = self.dataSource.users[indexPath.row];
    
	
	return cell;
}

@end
