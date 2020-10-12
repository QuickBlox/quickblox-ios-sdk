//
//  UsersInfoTableViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UsersInfoTableViewController.h"
#import "AddOccupantsController.h"
#import "UserTableViewCell.h"
#import "ChatManager.h"
#import "Profile.h"
#import "QBUUser+Chat.h"
#import "UIColor+Chat.h"
#import "TitleView.h"
#import "SVProgressHUD.h"

NSString *const DELIVERED = @"Message delivered to";
NSString *const VIEWED = @"Message viewed by";

@interface UsersInfoTableViewController () <ChatManagerDelegate, QBChatDelegate>
#pragma mark - Properties
@property (nonatomic, strong) NSArray<QBUUser *> *users;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) Profile *currentUser;
@property (nonatomic, strong) UIBarButtonItem *addUsersItem;
@end

@implementation UsersInfoTableViewController
#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [QBChat.instance addDelegate: self];
    
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;
    
    self.chatManager = [ChatManager instance];
    self.chatManager.delegate = self;
    
    UINib *nibUserCell = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:nibUserCell forCellReuseIdentifier:@"UserTableViewCell"];
    
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    
    self.currentUser = [[Profile alloc] init];
    [self setupUsers];
    self.addUsersItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_user"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(didTapAddUsers:)];
    self.navigationItem.rightBarButtonItem = self.addUsersItem;
    self.addUsersItem.tintColor = UIColor.whiteColor;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    if (self.action == ChatActionsChatInfo) {
        self.addUsersItem.tintColor = UIColor.whiteColor;
        self.addUsersItem.enabled = YES;
    } else {
        self.addUsersItem.tintColor = UIColor.clearColor;
        self.addUsersItem.enabled = NO;
    }
    
    __weak __typeof(self)weakSelf = self;
    self.dialog.onJoinOccupant = ^(NSUInteger userID) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (userID == self.currentUser.ID) {
            return;
        }
        [strongSelf chatDidBecomeOnlineUser:@(userID)];
    };
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [QBChat.instance removeDelegate:self];
}

#pragma mark - Setup
- (void)setupNavigationTitle {
    NSString *title = self.dialog.name;
    if (self.action == ChatActionsViewedBy) {
        title = VIEWED;
    } else if (self.action == ChatActionsDeliveredTo) {
        title = DELIVERED;
    }
    NSString *numberUsers = [NSString stringWithFormat:@"%@ members", @(self.users.count)];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

- (void)chatDidBecomeOnlineUser:(NSNumber *)userID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
    QBUUser *onlineUser = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    
    if (onlineUser) {
        NSMutableArray *arrayOfUsers = [NSMutableArray arrayWithArray:self.users.copy];
        NSInteger index = [arrayOfUsers indexOfObject:onlineUser];
        [arrayOfUsers removeObject:onlineUser];
        [arrayOfUsers insertObject:onlineUser atIndex:0];
        self.users = arrayOfUsers.copy;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSIndexPath * indexPathFirst = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView insertRowsAtIndexPaths:@[indexPathFirst] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAddUsers:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_ADD_OPPONENTS", nil) sender:nil];
}

#pragma mark - Internal Methods
- (void)updateUsers {
    QBChatDialog *dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    if (dialog.occupantIDs.count > 0) {
        [self setupUsers];
    }
}

- (void)setupUsers {
    NSMutableArray *array = [NSMutableArray array];
    Profile *currentUser = [[Profile alloc] init];
    
    switch (self.action) {
        case ChatActionsViewedBy:
            for (NSNumber *readID in self.message.readIDs) {
                if (readID.unsignedIntValue == currentUser.ID) {
                    continue;
                }
                QBUUser *user = [self.chatManager.storage userWithID:readID.unsignedIntValue];
                if (user) {
                    [array addObject:user];
                }
                self.users = array.copy;
            }
            break;
        case ChatActionsDeliveredTo:
            for (NSNumber *deliveredID in self.message.deliveredIDs) {
                if (deliveredID.unsignedIntValue == currentUser.ID) {
                    continue;
                }
                QBUUser *user = [self.chatManager.storage userWithID:deliveredID.unsignedIntValue];
                if (user) {
                    [array addObject:user];
                }
                self.users = array.copy;
            }
            break;
        case ChatActionsChatInfo:
            self.users = [self.chatManager.storage usersWithDialogID:self.dialogID];
            break;
            
        default:
            break;
    }
    
    [self setupNavigationTitle];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

#pragma mark - Helpers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_ADD_OPPONENTS", nil)]) {
        AddOccupantsController *addOccupantsVC = segue.destinationViewController;
        addOccupantsVC.dialogID = self.dialogID;
    }
}

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UserTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    QBUUser *user = self.users[indexPath.row];
    cell.userColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%lX",
                                                  (unsigned long)user.ID]];
    NSString *userName = user.fullName.length ? user.fullName : user.login;
    if (self.currentUser.ID == user.ID) {
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", userName,  @"(You)"];
    } else {
        cell.userNameLabel.text = userName;
    }
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [user.fullName stringByTrimmingCharactersInSet:characterSet];
    NSString *firstLetter = [name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    cell.userAvatarLabel.text = firstLetter;
    cell.tag = indexPath.row;
    cell.checkBoxView.hidden = YES;
    cell.checkBoxImageView.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
    [self setupUsers];
}

- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_USERS", nil)];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if ([chatDialog.ID isEqualToString: self.dialogID]) {
        [self updateUsers];
    }
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

#pragma mark - QBChatDelegate
- (void)chatDidReadMessageWithID:(NSString *)messageID
                        dialogID:(NSString *)dialogID
                        readerID:(NSUInteger)readerID {
    if (!self.dataSource) {
        return;
    }
    if (self.currentUser.ID == readerID
        || ![dialogID isEqualToString:self.dialogID]
        || self.action != ChatActionsViewedBy
        || ![self.message.ID isEqualToString:messageID]) {
        return;
    }
    QBChatMessage *readedMessage = [self.dataSource messageWithID:messageID];
    if (readedMessage) {
        NSMutableArray *readIDs = [readedMessage.readIDs mutableCopy];
        if ([readIDs containsObject:@(readerID)]) {
            return;
        }
        [readIDs addObject:@(readerID)];
        [readedMessage setReadIDs: [readIDs copy]];
        [self.dataSource updateMessage:readedMessage];
        
        self.message = readedMessage;
        [self updateUsers];
    }
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID {
    if (!self.dataSource) {
        return;
    }
    if (self.currentUser.ID == userID
        || ![dialogID isEqualToString:self.dialogID]
        || self.action != ChatActionsDeliveredTo
        || ![self.message.ID isEqualToString:messageID]) {
        return;
    }
    QBChatMessage *deliveredMessage = [self.dataSource messageWithID:messageID];
    if (deliveredMessage) {
        NSMutableArray *deliveredIDs = [deliveredMessage.deliveredIDs mutableCopy];
        if ([deliveredIDs containsObject:@(userID)]) {
            return;
        }
        [deliveredIDs addObject:@(userID)];
        [deliveredMessage setDeliveredIDs: [deliveredIDs copy]];
        [self.dataSource updateMessage:deliveredMessage];
        
        self.message = deliveredMessage;
        [self updateUsers];
    }
}

@end
