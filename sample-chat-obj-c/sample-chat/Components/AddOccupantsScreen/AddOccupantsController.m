//
//  NewAddOccupantsController.m
//  sample-chat
//
//  Created by Injoit on 19.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "AddOccupantsController.h"
#import "SearchUsersViewController.h"
#import "UserListViewController.h"
#import "ChatViewController.h"
#import "TitleView.h"
#import "Users.h"
#import "UIViewController+Alert.h"
#import "SearchBarView.h"
#import "ChatManager.h"

NSString *const ADD_MEMBERS = @"Add Members";

@interface AddOccupantsController () <SearchBarViewDelegate, QBChatDelegate>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet SearchBarView *searchBarView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

//MARK: - Properties
@property (strong, nonatomic) UserListViewController *current;
@property (strong, nonatomic) TitleView *navigationTitleView;
@property (strong, nonatomic) Users *users;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) QBChatDialog *dialog;
@end

@implementation AddOccupantsController
//MARK - Setup
- (void)setCurrent:(UserListViewController *)current {
    _current = current;
    [self.current setupSelectedUsers:self.users.selected.allObjects];
    
    __weak __typeof(self)weakSelf = self;
    [_current setOnSelectUser:^(QBUUser * _Nonnull user, BOOL isSelect) {
        if (!isSelect) {
            [weakSelf.users.selected removeObject:user];
        } else {
            [weakSelf.users.selected addObject:user];
        }
        [weakSelf setupNavigationTitle];
        [weakSelf checkCreateChatButtonState];
    }];
    
    [_current setOnFetchedUsers:^(NSArray<QBUUser *> * _Nonnull users) {
        Profile *profile = [[Profile alloc] init];
        for (QBUUser *user in users) {
            if (user.ID == profile.ID) { continue; }
            weakSelf.users.users[@(user.ID)] = user;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QBChat.instance addDelegate: self];
    self.chatManager = [ChatManager instance];
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    self.users = [[Users alloc] init];
    self.searchBarView.delegate = self;
    self.navigationTitleView = [[TitleView alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = self.navigationTitleView;
    [self setupNavigationTitle];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(addOccupantsButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButtonItem;
    createButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UserListViewController *fetchUsersViewController =
    [[UserListViewController alloc] initWithNonDisplayedUsers:self.dialog.occupantIDs];
    self.current = fetchUsersViewController;
    [self changeCurrentViewController:fetchUsersViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDialog:)
                                                 name:UpdatedChatDialogNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Configuration
- (void)showFetchScreen {
    UserListViewController *fetchUsersViewController =
    [[UserListViewController alloc] initWithNonDisplayedUsers:self.dialog.occupantIDs];
    [self changeCurrentViewController:fetchUsersViewController];
}

- (void)showSearchScreenWithSearchText:(NSString *)searchText {
    SearchUsersViewController *searchUsersViewController =
    [[SearchUsersViewController alloc] initWithNonDisplayedUsers:self.dialog.occupantIDs searchText:searchText];
    [self changeCurrentViewController:searchUsersViewController];
}

- (void)changeCurrentViewController:(UserListViewController *)newCurrentViewController {
    [self addChildViewController:newCurrentViewController];
    newCurrentViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:newCurrentViewController.view];
    [newCurrentViewController didMoveToParentViewController:self];
    if ([self.current isEqual:newCurrentViewController]) {
        return;
    }
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    self.current = newCurrentViewController;
}

- (void)setupNavigationTitle {
    NSString *users = self.users.selected.count == 1 ? @"user" : @"users";
    NSString *numberUsers = [NSString stringWithFormat:@"%@ %@ selected", @(self.users.selected.count), users];
    [self.navigationTitleView setupTitleViewWithTitle:ADD_MEMBERS subTitle:numberUsers];
}

//MARK: - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addOccupantsButtonPressed:(UIButton *)sender {
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    sender.enabled = NO;
    NSArray *selectedUsers = self.users.selected.allObjects;
    [self.chatManager.storage updateUsers:selectedUsers];
    NSMutableArray *newUsersIDs = [NSMutableArray array];
    
    for (QBUUser *user in selectedUsers) {
        [newUsersIDs addObject:@(user.ID)];
    }
    NSArray *usersIDs = [newUsersIDs copy];
    // Updates dialog with new occupants.
    __weak __typeof(self)weakSelf = self;
    [self.chatManager joinOccupantsWithIDs:usersIDs
                                  toDialog:self.dialog
                                completion:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull updatedDialog) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (!updatedDialog || response.error) {
            sender.enabled = YES;
            [weakSelf showAlertWithTitle:nil
                                 message:response.error.error.localizedDescription
                                 handler:nil];
            return;
        }
        NSArray *controllers = strongSelf.navigationController.viewControllers;
        NSMutableArray *newStack = [NSMutableArray array];
        
        //change stack by replacing view controllers after ChatVC with ChatVC
        for (UIViewController *controller in controllers) {
            [newStack addObject:controller];
            if ([controller isKindOfClass:[ChatViewController class]]) {
                ChatViewController *chatController = (ChatViewController *)controller;
                chatController.dialogID = updatedDialog.ID;
                [strongSelf.navigationController setViewControllers:[newStack copy]];
                return;
            }
        }
    }];
}

#pragma mark - Helpers
- (void)checkCreateChatButtonState {
    self.navigationItem.rightBarButtonItem.enabled = self.users.selected.count > 0;
}

#pragma mark SearchBarViewDelegate
- (void)searchBarView:(SearchBarView *)searchBarView didChangeSearchText:(NSString *)searchText {
    if ([self.current isKindOfClass:[SearchUsersViewController class]]) {
        SearchUsersViewController *searchUsersViewController = (SearchUsersViewController *)self.current;
        searchUsersViewController.searchText = searchText;
    } else {
        if (searchText.length > 2) {
            [self showSearchScreenWithSearchText:searchText];
        }
    }
}

- (void)searchBarView:(SearchBarView *)searchBarView didCancelSearchButtonTapped:(nonnull UIButton *)sender {
    [self showFetchScreen];
}

#pragma mark Notification methods
- (void)updateDialog:(NSNotification *)notification {
    NSString *chatDialogId = [notification.userInfo objectForKey:UpdatedChatDialogNotificationKey];
    if (!chatDialogId || ![chatDialogId isEqualToString:self.dialogID]) { return; }
    self.dialog = [self.chatManager.storage dialogWithID:chatDialogId];
    if (!self.dialog) { return; }
    self.current.userList.nonDisplayedUsers = self.dialog.occupantIDs;
}

@end
