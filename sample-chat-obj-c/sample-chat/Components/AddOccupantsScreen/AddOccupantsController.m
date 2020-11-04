//
//  AddOccupantsController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AddOccupantsController.h"
#import "ChatManager.h"
#import "Profile.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "UserTableViewCell.h"
#import "Log.h"
#import "QBUUser+Chat.h"
#import "UIColor+Chat.h"
#import "TitleView.h"
#import "UITableView+Chat.h"
#import "Reachability.h"
#import "UIView+Chat.h"
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

NSString *const ADD_OCCUPANTS = @"Add Occupants";
NSString *const NO_USERS_FOUND = @"No user with that name";
const NSUInteger kPerPageUsers = 100;

@interface AddOccupantsController () <ChatManagerDelegate, UISearchBarDelegate>
//MARK: - Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelSearchButton;

@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *users;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *downloadedUsers;
@property (nonatomic, strong) NSMutableSet<QBUUser *> *selectedUsers;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *foundedUsers;
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, assign) Boolean cancel;
@property (nonatomic, assign) Boolean cancelFetch;
@property (nonatomic, assign) Boolean isSearch;
@property (nonatomic, assign) NSUInteger currentFetchPage;
@property (nonatomic, assign) NSUInteger currentSearchPage;
@end

@implementation AddOccupantsController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedUsers = [NSMutableSet set];
    self.users = [NSMutableArray array];
    self.downloadedUsers = [NSMutableArray array];
    self.foundedUsers = [NSMutableArray array];
    self.cancel = NO;
    self.cancelFetch = NO;
    self.isSearch = NO;
    self.currentFetchPage = 1;
    self.currentSearchPage = 1;
    
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;
    [self setupNavigationTitle];
    
    self.chatManager = [ChatManager instance];
    self.chatManager.delegate = self;
    
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    
    [self checkCreateChatButtonState];
    
    UINib *nibUserCell = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:nibUserCell forCellReuseIdentifier:@"UserTableViewCell"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(addOccupantsButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButtonItem;
    createButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupViews];
    
    // Reachability
    void (^updateLoginInfo)(NetworkStatus status) = ^(NetworkStatus status) {
        if (status == NetworkStatusNotReachable) {
            [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                             message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
                  fromViewController:self];
        } else {
            [self fetchUsers];
        }
    };
    
    Reachability.instance.networkStatusBlock = ^(NetworkStatus status) {
        updateLoginInfo(status);
    };
    updateLoginInfo(Reachability.instance.networkStatus);
}

#pragma mark - Setup
- (void)setupViews {
    UIImageView *iconSearch = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    iconSearch.frame = CGRectMake(0.0f, 0.0f, 28.0f, 28.0f);
    iconSearch.contentMode = UIViewContentModeCenter;
    [self.searchBar setRoundBorderEdgeColorView:0.0f borderWidth:1.0f color:nil borderColor:UIColor.whiteColor];
    UITextField *searchTextField = [self.searchBar valueForKey:@"searchField"];
    if (searchTextField) {
        UILabel *systemPlaceholderLabel = [searchTextField valueForKey:@"placeholderLabel"];
        if (systemPlaceholderLabel) {
            
            // Create custom placeholder label
            UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            placeholderLabel.backgroundColor = UIColor.whiteColor;
            placeholderLabel.text = @"Search";
            placeholderLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightRegular];
            placeholderLabel.textColor = [UIColor colorWithRed:0.43f green:0.48f blue:0.57f alpha:1.0f];
            
            [systemPlaceholderLabel addSubview:placeholderLabel];
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [placeholderLabel.leftAnchor constraintEqualToAnchor:systemPlaceholderLabel.leftAnchor].active = YES;
            [placeholderLabel.topAnchor constraintEqualToAnchor:systemPlaceholderLabel.topAnchor].active = YES;
            [placeholderLabel.rightAnchor constraintEqualToAnchor:systemPlaceholderLabel.rightAnchor].active = YES;
            [placeholderLabel.bottomAnchor constraintEqualToAnchor:systemPlaceholderLabel.bottomAnchor].active = YES;
        }
        searchTextField.leftView = iconSearch;
        searchTextField.backgroundColor = UIColor.whiteColor;
        searchTextField.clearButtonMode = UITextFieldViewModeNever;
    }
    
    self.searchBar.showsCancelButton = NO;
    self.cancelSearchButton.hidden = YES;
}

- (void)setupNavigationTitle {
    NSString *title = ADD_OCCUPANTS;
    NSString *users = @"users";
    if (self.selectedUsers.count == 1) {
        users = @"user";
    }
    NSString *numberUsers = [NSString stringWithFormat:@"%@ %@ selected", @(self.selectedUsers.count), users];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

#pragma mark - Internal Methods
- (void)fetchUsers {
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [self.chatManager fetchUsersWithCurrentPage:self.currentFetchPage
                                        perPage:kPerPageUsers
                                     completion:^(QBResponse * _Nonnull response, NSArray<QBUUser *> * _Nonnull users, Boolean cancel) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        strongSelf.cancelFetch = cancel;
        if (cancel == false) {
            strongSelf.currentFetchPage += 1;
        }
        [strongSelf.downloadedUsers addObjectsFromArray:users];
        [strongSelf setupUsers:strongSelf.downloadedUsers];
        if (strongSelf.users.count) {
            [strongSelf.tableView removeEmptyView];
        } else {
            [strongSelf.tableView setupEmptyViewWithAlert:NO_USERS_FOUND];
        }
    }];
}

- (void)searchUsersName:(NSString *)text {
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [self.chatManager searchUsersName:text
                          currentPage:self.currentSearchPage
                              perPage:kPerPageUsers
                           completion:^(QBResponse * _Nonnull response, NSArray<QBUUser *> * _Nonnull users, Boolean cancel) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        strongSelf.cancel = cancel;
        if (strongSelf.currentSearchPage == 1) {
            [strongSelf.foundedUsers removeAllObjects];
        }
        if (cancel == false) {
            strongSelf.currentSearchPage += 1;
        }
        [strongSelf addFoundUsers:users];
        if (strongSelf.users.count) {
            [strongSelf.tableView removeEmptyView];
        } else {
            [strongSelf.tableView setupEmptyViewWithAlert:NO_USERS_FOUND];
        }
    }];
}

- (void)addFoundUsers:(NSArray<QBUUser *> *)users {
    NSMutableArray<QBUUser *> *filteredUsers = [NSMutableArray array];
    Profile *currentUser = [[Profile alloc] init];
    
    for (QBUUser *user in users) {
        if (user.ID == currentUser.ID) {
            continue;
        }
        if (![self.dialog.occupantIDs containsObject:@(user.ID)]) {
            [filteredUsers addObject:user];
        }
    }
    NSMutableSet<QBUUser *> *removedUsers = [NSMutableSet set];
    for (QBUUser *user in self.selectedUsers) {
        if ([self.dialog.occupantIDs containsObject:@(user.ID)]) {
            [removedUsers addObject:user];
        }
    }
    [self.selectedUsers minusSet:removedUsers];
    
    [self.foundedUsers addObjectsFromArray:filteredUsers.copy];
    
    self.users = self.foundedUsers;
    [self.tableView reloadData];
    [self checkCreateChatButtonState];
}

- (void)setupUsers:(NSArray <QBUUser *> *)users {
    
    [self.users removeAllObjects];
    
    Profile *currentUser = [[Profile alloc] init];
    
    NSArray *occupantIDs = self.dialog.occupantIDs;
    
    for (QBUUser *user in users) {
        if (user.ID == currentUser.ID) {
            continue;
        }
        if (![occupantIDs containsObject:@(user.ID)]) {
            [self.users addObject:user];
        }
    }
    NSMutableSet<QBUUser *> *removedUsers = [NSMutableSet set];
    for (QBUUser *user in self.selectedUsers) {
        if ([occupantIDs containsObject:@(user.ID)]) {
            [removedUsers addObject:user];
        }
    }
    [self.selectedUsers minusSet:removedUsers];
    
    if (self.selectedUsers.count) {
        NSMutableSet *usersSet = [NSMutableSet setWithArray:self.users.copy];
        for (QBUUser *user in self.selectedUsers) {
            if (![usersSet containsObject:user]) {
                [self.users insertObject:user atIndex:0];
                [usersSet addObject:user];
            }
        }
    }
    
    [self checkCreateChatButtonState];
    [self.tableView reloadData];
}

- (void)openNewDialog:(QBChatDialog *)newDialog {
    NSArray *controllers = self.navigationController.viewControllers;
    NSMutableArray *newStack = [NSMutableArray array];
    
    //change stack by replacing view controllers after ChatVC with ChatVC
    for (UIViewController *controller in controllers) {
        [newStack addObject:controller];
        
        if ([controller isKindOfClass:[DialogsViewController class]]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
            ChatViewController *chatController = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatController.dialogID = newDialog.ID;
            [newStack addObject:chatController];
            NSArray *newControllers = [newStack copy];
            [self.navigationController setViewControllers:newControllers];
            return;
        }
    }
    
    //else perform segue
    [self performSegueWithIdentifier:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_CHAT", nil) sender:newDialog.ID];
}

#pragma mark - Helpers
- (void)checkCreateChatButtonState {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedUsers.count > 0;
}

- (NSString *)systemMessageWithUsers:(NSArray<QBUUser *> *)users {
    NSString *actionMessage = NSLocalizedString(@"SA_STR_ADDED", nil);
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return @"";
    }
    NSString *message = [NSString stringWithFormat:@"%@ %@ ", currentUser.fullName, actionMessage];
    for (QBUUser *user in users) {
        if (!user.fullName) {
            continue;
        }
        message = [NSString stringWithFormat:@"%@%@,", message, user.fullName];
    }
    message = [message substringToIndex:message.length - 1];
    return message;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_CHAT", nil)]) {
        ChatViewController *chatController = [segue destinationViewController];
        chatController.dialogID = sender;
    }
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelSearchButtonTapped:(id)sender {
    self.cancelSearchButton.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.isSearch = NO;
    self.cancel = NO;
    [self setupUsers:self.downloadedUsers];
}

- (void)addOccupantsButtonPressed:(UIButton *)sender {
    if (Reachability.instance.networkStatus == NetworkStatusNotReachable) {
        [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                         message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
              fromViewController:self];
        [SVProgressHUD dismiss];
        return;
    }
    
    self.cancelSearchButton.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.isSearch = NO;
    sender.enabled = NO;
    NSArray *selectedUsers = self.selectedUsers.allObjects;
    
    if (self.dialog.type == QBChatDialogTypeGroup) {
        [SVProgressHUD show];
        NSMutableArray *mutUsersIDs = [NSMutableArray array];
        
        for (QBUUser *user in selectedUsers) {
            [mutUsersIDs addObject:@(user.ID)];
        }
        NSArray *usersIDs = [mutUsersIDs copy];
        // Updates dialog with new occupants.
        [self.chatManager joinOccupantsWithIDs:usersIDs toDialog:self.dialog completion:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull updatedDialog) {
            if (!updatedDialog || response.error) {
                sender.enabled = YES;
                [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
                return;
            }
            NSString *message = [self systemMessageWithUsers:selectedUsers];
            
            [self.chatManager sendAddingMessage:message action:DialogActionTypeAdd withUsers:usersIDs toDialog:updatedDialog completion:^(NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                [self checkCreateChatButtonState];
                [self openNewDialog:updatedDialog];
            }];
        }];
    }
}

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.users.count == 0 && self.isSearch == YES) {
        [self.tableView setupEmptyViewWithAlert:NO_USERS_FOUND];
    } else {
        [self.tableView removeEmptyView];
    }
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
    cell.userNameLabel.text = user.fullName.length ? user.fullName : user.login;
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [user.fullName stringByTrimmingCharactersInSet:characterSet];
    NSString *firstLetter = [name substringToIndex:1];
    firstLetter = [firstLetter uppercaseString];
    cell.userAvatarLabel.text = firstLetter;
    cell.tag = indexPath.row;
    
    NSUInteger lastItemNumber = self.users.count - 1;
    if (indexPath.row == lastItemNumber) {
        if (self.isSearch == YES && self.cancel == NO) {
            if (self.searchBar.text) {
                [self searchUsersName:self.searchBar.text];
            }
        } else if (self.isSearch == NO && self.cancelFetch == NO) {
            [self fetchUsers];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    [self.selectedUsers addObject:user];
    [self setupNavigationTitle];
    [self checkCreateChatButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    if ([self.selectedUsers containsObject:user]) {
        [self.selectedUsers removeObject:user];
    }
    [self setupNavigationTitle];
    [self checkCreateChatButtonState];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    if ([self.selectedUsers containsObject:user]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.cancelSearchButton.hidden = NO;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length > 2) {
        self.isSearch = YES;
        
        [SVProgressHUD show];
        self.currentSearchPage = 1;
        self.cancel = NO;
        [self searchUsersName:searchText];
    }
    if (searchText.length == 0) {
        self.isSearch = NO;
        self.cancel = NO;
        [self setupUsers:self.downloadedUsers];
    }
}

#pragma mark Chat Manager Delegate
- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_USERS", nil)];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if ([chatDialog.ID isEqualToString: self.dialogID]) {
        self.dialog = chatDialog;
        [self setupUsers:self.users.copy];
    }
}

@end
