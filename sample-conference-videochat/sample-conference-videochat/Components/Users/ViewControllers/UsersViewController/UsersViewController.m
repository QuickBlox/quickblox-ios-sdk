//
//  UsersViewController.m
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UsersViewController.h"
#import <Quickblox/Quickblox.h>
#import "QBCore.h"
#import "UsersDataSource.h"
#import "QBDataFetcher.h"
#import "SVProgressHUD.h"

@implementation UsersViewController

// MARK: Lifecycle

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.rowHeight = 44;
    
    // adding refresh control task
    if (self.refreshControl) {
        
        [self.refreshControl addTarget:self
                                action:@selector(fetchData)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    UIBarButtonItem *createChatButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didPressCreateChatButton:)];
    
    self.navigationItem.rightBarButtonItem = createChatButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.refreshControl.refreshing) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        [self.dataSource deselectAllObjects];
    }
}

- (void)didPressCreateChatButton:(UIBarButtonItem *)item {
    
    if ([self hasConnectivity]) {
        
        NSArray *selectedUsers = self.dataSource.selectedObjects;
        NSArray *userIDs = [selectedUsers valueForKeyPath:@"ID"];
        NSArray *userNames = [selectedUsers valueForKey:@"fullName"];
        QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
        chatDialog.occupantIDs = userIDs;
        chatDialog.name = [NSString stringWithFormat:@"%@, %@", Core.currentUser.fullName, [userNames componentsJoinedByString:@", "]];
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Creating chat dialog.", nil)];
        __weak __typeof(self)weakSelf = self;
        [QBRequest createDialog:chatDialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nullable createdDialog) {
            
            [SVProgressHUD dismiss];
            [weakSelf.delegate usersViewController:weakSelf didCreateChatDialog:createdDialog];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", response.error.reasons]];
        }];
    }
}

// MARK: UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource selectObjectAtIndexPath:indexPath];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    self.navigationItem.rightBarButtonItem.enabled = self.dataSource.selectedObjects.count > 0;
}

// MARK: Actions

- (BOOL)hasConnectivity {
    
    BOOL hasConnectivity = Core.networkStatus != QBNetworkStatusNotReachable;
    
    if (!hasConnectivity) {
        [self showAlertViewWithMessage:NSLocalizedString(@"Please check your Internet connection", nil)];
    }
    
    return hasConnectivity;
}

- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// MARK: Private

- (void)fetchData {
    
    __weak __typeof(self)weakSelf = self;
    [QBDataFetcher fetchUsers:^(NSArray *users) {
        
        [weakSelf.dataSource setObjects:users];
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
    }];
}

@end
