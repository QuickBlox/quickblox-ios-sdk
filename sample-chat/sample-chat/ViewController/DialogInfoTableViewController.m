//
//  DialogInfoTableViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "DialogInfoTableViewController.h"
#import "UsersDataSource.h"
#import "StorageManager.h"
#import "QBServicesManager.h"

@interface DialogInfoTableViewController()

@property (nonatomic, strong) UsersDataSource* usersDatasource;

@end

@implementation DialogInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	__weak __typeof(self) weakSelf = self;
	[QBServicesManager.instance.usersService retrieveUsersWithIDs:self.dialog.occupantIDs completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
		weakSelf.usersDatasource = [[UsersDataSource alloc] initWithUsers:users];
		weakSelf.tableView.dataSource = weakSelf.usersDatasource;
		[weakSelf.tableView reloadData];
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kShowDialogInfoViewController"]) {
        DialogInfoTableViewController* viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

@end
