//
//  BaseUsersViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 08.02.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "BaseUsersViewController.h"
#import "Log.h"
#import "QBUUser+Chat.h"
#import "UIColor+Chat.h"
#import "UITableView+Chat.h"
#import "UIView+Chat.h"
#import "EnterChatNameVC.h"
#import "UIViewController+Alert.h"
#import "NSString+Chat.h"
#import "ChatManager.h"

NSString *const NO_USERS = @"No user with that name";
const NSUInteger kPerPage = 100;
const CGFloat searchBarHeight = 44.0f;;

@interface BaseUsersViewController ()

@end

@interface BaseUsersViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
#pragma mark - Properties
@property (nonatomic, strong) NSString *searchText;

@end

@implementation BaseUsersViewController
#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.users = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navBarTitle = @"";
    self.searchText = @"";
    self.selectedUsers = [NSMutableSet set];
    self.downloadedUsers = [NSMutableArray array];
    self.foundedUsers = [NSMutableArray array];
    self.cancel = NO;
    self.cancelFetch = NO;
    self.isSearch = NO;
    self.useSearchBar = YES;
    self.currentFetchPage = 1;
    self.currentSearchPage = 1;
    
    // configure it if necessary.
    [self isUseSearchBar];
    [self setupNavigationBar];
    /////////////////////////////////////////////////////////////
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;
    
    self.chatManager = [ChatManager instance];
    [self checkCreateChatButtonState];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.98f alpha:1.0f];
    UINib *nibUserCell = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:nibUserCell forCellReuseIdentifier:@"UserTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60.0f;
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    
    if (self.useSearchBar) {
        self.cancelSearchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cancelSearchButton setImage:[UIImage imageNamed:@"ic_cancel"] forState:UIControlStateNormal];
        self.cancelSearchButton.tintColor = [UIColor colorWithRed:0.43f green:0.48f blue:0.57f alpha:1.0f];
        self.cancelSearchButton.enabled = YES;
        [self.cancelSearchButton addTarget:self action:@selector(cancelSearchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.cancelSearchButton];
        self.cancelSearchButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cancelSearchButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.cancelSearchButton.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor].active = YES;
        [self.cancelSearchButton.widthAnchor constraintEqualToConstant:56.0f].active = YES;
        [self.cancelSearchButton.heightAnchor constraintEqualToConstant:searchBarHeight].active = YES;
        self.cancelSearchButton.hidden = YES;

        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        self.searchBar.barTintColor = UIColor.whiteColor;
        self.searchBar.translucent = YES;
        self.searchBar.placeholder = @"Search";
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = NO;
        [self.view addSubview:self.searchBar];
        self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.searchBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.searchBar.rightAnchor constraintEqualToAnchor:self.cancelSearchButton.leftAnchor constant: -2.0f].active = YES;
        [self.searchBar.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
        [self.searchBar.heightAnchor constraintEqualToConstant:searchBarHeight].active = YES;
        [self setupSearchBarViews];
        
        self.tableView.allowsMultipleSelection = YES;
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    } else {
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!QBSession.currentSession.currentUser) {
        return;
    }
    self.currentUser = QBSession.currentSession.currentUser;
    
    // configure it if necessary.
    [self setupFetchUsers];
    [self setupViewWillAppear];
    [self setupNavigationTitle];
}

#pragma mark - Setup
- (void)setupNavigationBar {
    // configure it if necessary.
}

- (void)setupFetchUsers {
    // configure it if necessary.
    if (!self.isSearch) {
        [self fetchUsers];
        
    } else {
        if (self.searchText.length > 2) {
            [self searchUsers:self.searchText];
        }
    }
}

- (void)setupViewWillAppear {
    // configure it if necessary.
}

- (void)isUseSearchBar {
    // configure it if necessary.
}

- (void)setupSearchBarViews {
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
}

- (void)setupNavigationTitle {
    NSString *title = self.navBarTitle;
    NSString *users = @"users";
    if (self.selectedUsers.count == 1) {
        users = @"user";
    }
    NSString *numberUsers = [NSString stringWithFormat:@"%@ %@ selected", @(self.selectedUsers.count), users];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

- (void)tableView:(UITableView *)tableView
         configureCell:(UserTableViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    NSUInteger lastItemNumber = self.users.count - 1;
    if (indexPath.row == lastItemNumber) {
        if (self.isSearch == YES && self.cancel == NO) {
            if (self.searchBar.text) {
                [self searchUsers:self.searchBar.text];
            }
        } else if (self.isSearch == NO && self.cancelFetch == NO) {
            [self fetchUsers];
        }
    }
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

- (void)searchUsers:(NSString *)text {
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
    // configure it if necessary.
}

- (void)addFoundUsers:(NSArray<QBUUser *> *)users {
    // configure it if necessary.
}

- (void)updateWithConnect {
    // configure it if necessary.
    [self setupFetchUsers];
}

#pragma mark - Helpers
- (void)checkCreateChatButtonState {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedUsers.count > 0;
}

//MARK: - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelSearchButtonTapped:(id)sender {
    self.cancelSearchButton.hidden = YES;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.isSearch = NO;
    self.cancel = NO;
    [self setupUsers:self.downloadedUsers];
}


#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.cancelSearchButton.hidden = NO;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 2) {
        self.isSearch = YES;
        
        [SVProgressHUD show];
        self.currentSearchPage = 1;
        self.cancel = NO;
        [self searchUsers:searchText];
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
    cell.userNameLabel.text = user.name;
    cell.userAvatarLabel.text = user.name.firstLetter;
    cell.tag = indexPath.row;
    
    [self tableView:tableView configureCell:cell forIndexPath:indexPath];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

@end

