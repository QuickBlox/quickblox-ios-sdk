//
//  DialogInfoTableViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "DialogInfoTableViewController.h"
#import "UsersDataSource.h"
#import "ServicesManager.h"
#import "EditDialogTableViewController.h"

@interface DialogInfoTableViewController() <QMChatServiceDelegate, QMChatConnectionDelegate>

@property (nonatomic, strong) UsersDataSource *usersDatasource;

@end

@implementation DialogInfoTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.title = NSLocalizedString(@"SA_STR_CHAT_INFO", nil);
    [self refreshDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ServicesManager instance].chatService addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ServicesManager instance].chatService removeDelegate:self];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if([self.dialog.ID isEqualToString:chatDialog.ID]) {
        self.dialog = chatDialog;
        [self refreshDataSource];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray *)dialogs {
    
    if ([dialogs containsObject:self.dialog]) {
        
        NSUInteger index = [dialogs indexOfObject:self.dialog];
        self.dialog = dialogs[index];
        [self refreshDataSource];
    }
}

#pragma mark - Helpers

- (void)refreshDataSource {
    __weak __typeof(self) weakSelf = self;
    
    // Retrieving users from cache.
    [[[ServicesManager instance].usersService getUsersWithIDs:self.dialog.occupantIDs] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.usersDatasource = [[UsersDataSource alloc] initWithUsers:task.result];
        strongSelf.tableView.dataSource = strongSelf.usersDatasource;
        
        if ([task.result count] >= [[ServicesManager instance].usersService.usersMemoryStorage unsortedUsers].count) {
            strongSelf.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else {
            strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        [strongSelf.tableView reloadData];
        
        return nil;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToAddOccupantsSegueIdentifier]) {
        EditDialogTableViewController *viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

@end
