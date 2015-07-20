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
#import "ServicesManager.h"
#import "EditDialogTableViewController.h"

@interface DialogInfoTableViewController() <QMChatServiceDelegate, QMChatConnectionDelegate>

@property (nonatomic, strong) UsersDataSource* usersDatasource;

@end

@implementation DialogInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self refreshDataSource];
}

- (void)refreshDataSource {
	__weak __typeof(self) weakSelf = self;
	[ServicesManager.instance.usersService retrieveUsersWithIDs:self.dialog.occupantIDs completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
		__typeof(self) strongSelf = weakSelf;
		strongSelf.usersDatasource = [[UsersDataSource alloc] initWithUsers:users];
		strongSelf.tableView.dataSource = weakSelf.usersDatasource;
		[strongSelf.tableView reloadData];
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[ServicesManager instance].chatService addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[ServicesManager instance].chatService removeDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGoToAddOccupantsSegueIdentifier]) {
        EditDialogTableViewController* viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog{
	if( [self.dialog.ID isEqualToString:chatDialog.ID] ) {
		self.dialog = chatDialog;
		[self refreshDataSource];
	}
}

@end
