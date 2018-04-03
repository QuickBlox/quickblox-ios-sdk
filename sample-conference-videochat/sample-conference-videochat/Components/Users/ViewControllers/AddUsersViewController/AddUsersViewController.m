//
//  AddUsersViewController.m
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "AddUsersViewController.h"
#import "UsersDataSource.h"
#import "SVProgressHUD.h"
#import "QBDataFetcher.h"

@interface AddUsersViewController ()

@property (strong, nonatomic) UsersDataSource *dataSource;

@end

@implementation AddUsersViewController

// MARK: Lifecycle

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [UsersDataSource usersDataSource];
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (QBUUser *user in self.usersDataSource.objects) {
        if (![self.chatDialog.occupantIDs containsObject:@(user.ID)]) {
            [users addObject:user];
        }
    }
    self.dataSource.objects = [users copy];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.rowHeight = 44;
    
    // adding refresh control task
    if (self.refreshControl) {
        
        [self.refreshControl addTarget:self
                                action:@selector(fetchData)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    UIBarButtonItem *createChatButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didPressUpdateChatButton:)];
    
    self.navigationItem.rightBarButtonItem = createChatButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.refreshControl.refreshing) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
}

- (void)didPressUpdateChatButton:(UIBarButtonItem *)item {
    
    [SVProgressHUD show];
    NSMutableArray *pushOccupantsIDs = [[NSMutableArray alloc] init];
    for (QBUUser *user in self.dataSource.selectedObjects) {
        [pushOccupantsIDs addObject:[NSString stringWithFormat:@"%tu", user.ID]];
    }
    self.chatDialog.pushOccupantsIDs = [pushOccupantsIDs copy];
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateDialog:self.chatDialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nullable chatDialog) {
        
        weakSelf.chatDialog.occupantIDs = chatDialog.occupantIDs;
        [SVProgressHUD dismiss];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", response.error.reasons]];
    }];
}


// MARK: UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource selectObjectAtIndexPath:indexPath];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    self.navigationItem.rightBarButtonItem.enabled = self.dataSource.selectedObjects.count > 0;
}

// MARK: Private

- (void)fetchData {
    
    __weak __typeof(self)weakSelf = self;
    [QBDataFetcher fetchUsers:^(NSArray *users) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        NSMutableArray *mutableUsers = [users mutableCopy];
        for (QBUUser *user in users) {
            if ([strongSelf.chatDialog.occupantIDs containsObject:@(user.ID)]) {
                [mutableUsers removeObject:user];
            }
        }
        [strongSelf.dataSource setObjects:[mutableUsers copy]];
        [strongSelf.tableView reloadData];
        [strongSelf.refreshControl endRefreshing];
    }];
}

@end
