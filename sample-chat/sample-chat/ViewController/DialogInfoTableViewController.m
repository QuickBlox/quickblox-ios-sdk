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
#import "EditDialogTableViewController.h"

@interface DialogInfoTableViewController() <QMChatServiceDelegate>

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
    [[QBServicesManager instance].chatService addDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGoToAddOccupantsSegueIdentifier]) {
        EditDialogTableViewController* viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog
{
    NSLog(@"Hit!");
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog
{
    NSLog(@"Hit!");
}

@end
