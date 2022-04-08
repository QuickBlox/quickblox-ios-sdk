//
//  CreateNewDialogViewController.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "CreateNewDialogViewController.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "EnterChatNameVC.h"
#import "SearchUsersViewController.h"
#import "UserListViewController.h"
#import "TitleView.h"
#import "Users.h"
#import "UIViewController+Alert.h"
#import "SearchBarView.h"
#import "ChatManager.h"
#import "Profile.h"

NSString *const NEW_CHAT = @"New Chat";

@interface CreateNewDialogViewController () <SearchBarViewDelegate, QBChatDelegate>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet SearchBarView *searchBarView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

//MARK: - Properties
@property (strong, nonatomic) UserListViewController *current;
@property (strong, nonatomic) TitleView *navigationTitleView;
@property (strong, nonatomic) Users *users;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) Profile *profile;
@end

@implementation CreateNewDialogViewController
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
    
    self.profile = [[Profile alloc] init];
    [QBChat.instance addDelegate: self];
    self.chatManager = [ChatManager instance];
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
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(createChatButtonPressed:)];
    self.navigationItem.rightBarButtonItem = createButtonItem;
    createButtonItem.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UserListViewController *fetchUsersViewController =
    [[UserListViewController alloc] initWithNonDisplayedUsers:@[@(self.profile.ID)]];
    self.current = fetchUsersViewController;
    [self changeCurrentViewController:fetchUsersViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
}

#pragma mark - UI Configuration
- (void)showFetchScreen {
    UserListViewController *fetchUsersViewController =
    [[UserListViewController alloc] initWithNonDisplayedUsers:@[@(self.profile.ID)]];
    [self changeCurrentViewController:fetchUsersViewController];
}

- (void)showSearchScreenWithSearchText:(NSString *)searchText {
    SearchUsersViewController *searchUsersViewController =
    [[SearchUsersViewController alloc] initWithNonDisplayedUsers:@[@(self.profile.ID)] searchText:searchText];
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

- (void)setupNavigationTitle {
    NSString *users = self.users.selected.count == 1 ? @"user" : @"users";
    NSString *numberUsers = [NSString stringWithFormat:@"%@ %@ selected", @(self.users.selected.count), users];
    [self.navigationTitleView setupTitleViewWithTitle:NEW_CHAT subTitle:numberUsers];
}

//MARK: - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helpers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"enterChatName"]) {
        EnterChatNameVC *chatNameVC = [segue destinationViewController];
        chatNameVC.selectedUsers = self.users.selected.allObjects;
    }
}

//MARK: - Actions
- (void)createChatButtonPressed:(UIButton *)sender {
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    NSArray *selectedUsers = self.users.selected.allObjects;
    
    Boolean isPrivate = selectedUsers.count == 1;
    
    if (isPrivate) {
        sender.enabled = NO;
        [self.chatManager.storage updateUsers:selectedUsers];
        QBUUser *user = selectedUsers.firstObject;
        if (!user) {
            sender.enabled = YES;
            return;
        }
        __weak __typeof(self)weakSelf = self;
        [self.chatManager createPrivateDialogWithOpponent:user
                                               completion:^(NSError * _Nullable error, QBChatDialog * _Nullable createdDialog) {
            __typeof(weakSelf)strongSelf = weakSelf;
            if (!createdDialog || error) {
                sender.enabled = YES;
                [weakSelf showAlertWithTitle:nil
                                     message:error.localizedDescription
                          fromViewController:self
                                     handler:nil];
                return;
            }
            NSArray *controllers = strongSelf.navigationController.viewControllers;
            NSMutableArray *newStack = [NSMutableArray array];
            
            //change stack by replacing view controllers after DialogsVC with ChatVC
            for (UIViewController *controller in controllers) {
                [newStack addObject:controller];
                if ([controller isKindOfClass:[DialogsViewController class]]) {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
                    ChatViewController *chatController = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                    chatController.dialogID = createdDialog.ID;
                    [newStack addObject:chatController];
                    [strongSelf.navigationController setViewControllers:[newStack copy]];
                    return;
                }
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"enterChatName" sender:nil];
    }
}

@end
