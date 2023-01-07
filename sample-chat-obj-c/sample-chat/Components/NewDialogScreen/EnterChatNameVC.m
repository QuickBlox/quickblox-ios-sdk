//
//  EnterChatNameVC.m
//  sample-chat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "EnterChatNameVC.h"
#import "InputContainer.h"
#import "TitleView.h"
#import "ChatManager.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "Log.h"
#import "UIView+Chat.h"
#import "UITextField+Chat.h"
#import "UIViewController+Alert.h"

NSString *const NAME_HINT = @"Must be in a range from 3 to 20 characters.";
NSString *const NAME_REGEX = @"^[^_]{3,19}$";
NSString *const NAME_TITLE = @"Chat Name";

@interface EnterChatNameVC () <InputContainerDelegate>
//MARK: - Properties
@property (strong, nonatomic) InputContainer *chatNameInputContainer;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) ChatManager *chatManager;

@end

@implementation EnterChatNameVC
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatNameInputContainer = [[NSBundle mainBundle] loadNibNamed:@"InputContainer" owner:nil options:nil].firstObject;
    [self.chatNameInputContainer setupWithTitle:NAME_TITLE hint:NAME_HINT regexes:@[NAME_REGEX]];
    [self.view addSubview:self.chatNameInputContainer];
    self.chatNameInputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chatNameInputContainer.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.chatNameInputContainer.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.chatNameInputContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16.0f].active = YES;
    [self.chatNameInputContainer inputTextfieldBecomeFirstResponder];
    [self.chatNameInputContainer layoutIfNeeded];
    self.chatNameInputContainer.delegate = self;
    
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;
    [self setupNavigationTitle];
    
    self.chatManager = [ChatManager instance];
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finish"
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

    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
}

#pragma mark - Setup

- (void)setupNavigationTitle {
    NSString *title = @"New Chat";
    NSString *numberUsers = [NSString stringWithFormat:@"%@ users selected", @(self.selectedUsers.count)];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

#pragma mark - Actions
- (IBAction)createChatButtonPressed:(UIButton *)sender {
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
    [self.chatManager.storage updateUsers:self.selectedUsers];
    NSString *chatName = self.chatNameInputContainer.text;
    sender.enabled = NO;
    __weak __typeof(self)weakSelf = self;
    [self.chatManager createGroupDialogWithName:chatName occupants:self.selectedUsers completion:^(NSError * _Nullable error, QBChatDialog * _Nullable createdDialog) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (!createdDialog || error) {
            sender.enabled = YES;
            [weakSelf showAlertWithTitle:nil
                                 message:error.localizedDescription
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
}

- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - InputContainerDelegate
- (void)inputContainer:(nonnull InputContainer *)inputContainer didChangeValidState:(BOOL)isValid {
    self.navigationItem.rightBarButtonItem.enabled = isValid;
}

@end
