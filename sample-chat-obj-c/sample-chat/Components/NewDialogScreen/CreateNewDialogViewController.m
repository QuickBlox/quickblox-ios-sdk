//
//  CreateNewDialogViewController.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CreateNewDialogViewController.h"
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
#import "EnterChatNameVC.h"
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

NSString *const NEW_CHAT = @"New Chat";
NSString *const NO_USERS = @"No user with that name";
const NSUInteger kPerPage = 100;

@interface CreateNewDialogViewController () <UISearchBarDelegate>
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelSearchButton;

@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *users;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *downloadedUsers;
@property (nonatomic, strong) NSMutableSet<QBUUser *> *selectedUsers;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *foundedUsers;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, assign) Boolean cancel;
@property (nonatomic, assign) Boolean cancelFetch;
@property (nonatomic, assign) Boolean isSearch;
@property (nonatomic, assign) NSUInteger currentFetchPage;
@property (nonatomic, assign) NSUInteger currentSearchPage;
@end

@implementation CreateNewDialogViewController
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
    
    if ([QBChat.instance isConnected]) {
        [self fetchUsers];
    }
    
    [self checkCreateChatButtonState];
    
    UINib *nibUserCell = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:nibUserCell forCellReuseIdentifier:@"UserTableViewCell"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(createChatButtonPressed:)];
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
    NSString *title = NEW_CHAT;
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
                                        perPage:kPerPage
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
            [strongSelf.tableView setupEmptyViewWithAlert:NO_USERS];
        }
    }];
}

- (void)searchUsersName:(NSString *)text {
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [self.chatManager searchUsersName:text
                          currentPage:self.currentSearchPage
                              perPage:kPerPage
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
            [strongSelf.tableView setupEmptyViewWithAlert:NO_USERS];
        }
    }];
}

- (void)setupUsers:(NSArray <QBUUser *> *)users {
    NSArray<QBUUser *> *filteredUsers = [NSArray array];
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID != %@", @(currentUser.ID)];
        filteredUsers = [users filteredArrayUsingPredicate:predicate];
    }
    self.users = [filteredUsers mutableCopy];
    if (self.selectedUsers.count) {
        NSMutableSet *usersSet = [NSMutableSet setWithArray:users];
        for (QBUUser *user in self.selectedUsers) {
            if (![usersSet containsObject:user]) {
                [self.users insertObject:user atIndex:0];
                [usersSet addObject:user];
            }
        }
    }
    [self.tableView reloadData];
    [self checkCreateChatButtonState];
}

- (void)addFoundUsers:(NSArray<QBUUser *> *)users {
    [self.foundedUsers addObjectsFromArray:users];
    NSArray<QBUUser *> *filteredUsers = @[];
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID != %@", @(currentUser.ID)];
        filteredUsers = [self.foundedUsers filteredArrayUsingPredicate:predicate];
    }
    self.users = [filteredUsers mutableCopy];
    [self.tableView reloadData];
    [self checkCreateChatButtonState];
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

- (NSString *)systemMessageWithAction:(DialogActionType)actionType withUsers:(NSArray<QBUUser *> *)users {
    NSString *actionMessage = NSLocalizedString(@"SA_STR_CREATE_NEW", nil);
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
    if ([segue.identifier isEqualToString:@"enterChatName"]) {
        EnterChatNameVC *chatNameVC = [segue destinationViewController];
        chatNameVC.selectedUsers = self.selectedUsers.allObjects;
    }
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_CHAT", nil)]) {
        ChatViewController *chatController = [segue destinationViewController];
        chatController.dialogID = sender;
    }
}

//MARK: - Actions
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

- (IBAction)createChatButtonPressed:(UIButton *)sender {
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
    
    NSArray *selectedUsers = self.selectedUsers.allObjects;
    
    Boolean isPrivate = selectedUsers.count == 1;
    
    if (isPrivate) {
        // Creating private chat.
        [SVProgressHUD show];
        [self.chatManager.storage updateUsers:selectedUsers];
        
        QBUUser *user = selectedUsers.firstObject;
        if (!user) {
            [SVProgressHUD dismiss];
            return;
        }
        [self.chatManager createPrivateDialogWithOpponent:user
                                               completion:^(QBResponse * _Nullable response, QBChatDialog * _Nullable createdDialog) {
            if (createdDialog) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"STR_DIALOG_CREATED", nil)];
                [self openNewDialog:createdDialog];
            } else if (response.error){
                [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
                return;
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"enterChatName" sender:nil];
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

#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.users.count == 0 && self.isSearch == YES) {
        [self.tableView setupEmptyViewWithAlert:NO_USERS];
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

@end
