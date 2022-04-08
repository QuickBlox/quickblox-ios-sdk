//
//  InfoUsersController.m
//  sample-chat
//
//  Created by Injoit on 22.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "InfoUsersController.h"
#import "AddOccupantsController.h"
#import "TitleView.h"
#import "ChatManager.h"
#import "QBUUser+Chat.h"
#import "UINavigationController+Appearance.h"
#import "UIViewController+Alert.h"

@interface InfoUsersController () <ChatManagerDelegate>
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) UIBarButtonItem *addUsersItem;
@property (strong, nonatomic) TitleView *navigationTitleView;
@property (nonatomic, strong) ChatManager *chatManager;
@end

@implementation InfoUsersController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = nil;
    self.chatManager = [ChatManager instance];
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    self.addUsersItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_user"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(didTapAddUsers:)];
    self.navigationItem.rightBarButtonItem = self.addUsersItem;
    self.addUsersItem.tintColor = UIColor.whiteColor;
    self.addUsersItem.enabled = YES;
    self.navigationTitleView = [[TitleView alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = self.navigationTitleView;
    [self setupUsers];
    
    __weak __typeof(self)weakSelf = self;
    self.dialog.onJoinOccupant = ^(NSUInteger userID) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (userID == self.profile.ID) {
            return;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", @(userID)];
        QBUUser *onlineUser = [[strongSelf.userList.fetched filteredArrayUsingPredicate:predicate] firstObject];
        
        if (!onlineUser) {
            return;
        }
        NSMutableArray *arrayOfUsers = [NSMutableArray arrayWithArray:strongSelf.userList.fetched.copy];
        NSInteger index = [arrayOfUsers indexOfObject:onlineUser];
        [arrayOfUsers removeObject:onlineUser];
        [arrayOfUsers insertObject:onlineUser atIndex:0];
        strongSelf.userList.fetched = arrayOfUsers.copy;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSIndexPath * indexPathFirst = [NSIndexPath indexPathForRow:0 inSection:0];
        [strongSelf.tableView beginUpdates];
        [strongSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [strongSelf.tableView insertRowsAtIndexPaths:@[indexPathFirst] withRowAnimation:UITableViewRowAnimationNone];
        [strongSelf.tableView endUpdates];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.chatManager.delegate = self;
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
}

#pragma mark - Setup
- (void)setupUsers {
    self.userList.fetched = [[self.chatManager.storage usersWithDialogID:self.dialogID] mutableCopy];
    [self.tableView reloadData];
    NSString *numberUsers = [NSString stringWithFormat:@"%@ members", @(self.userList.fetched.count)];
    [self.navigationTitleView setupTitleViewWithTitle:self.dialog.name subTitle:numberUsers];
}

- (void)tableView:(UITableView *)tableView
         configureCell:(UserTableViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    cell.checkBoxView.hidden = YES;
    cell.checkBoxImageView.hidden = YES;
    cell.userInteractionEnabled = NO;
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAddUsers:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
    AddOccupantsController *addOccupantsVC = [storyboard instantiateViewControllerWithIdentifier:@"AddOccupantsController"];
    addOccupantsVC.dialogID = self.dialogID;
    [self.navigationController pushViewController:addOccupantsVC animated:YES ];
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    if (![chatDialog.ID isEqualToString: self.dialogID]) {
        return;
    }
    self.dialog = chatDialog;
    [self setupUsers];
}

@end
