//
//  EnterChatNameVC.m
//  samplechat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "EnterChatNameVC.h"
#import "TitleView.h"
#import "ChatManager.h"
#import "Profile.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "Log.h"
#import "Reachability.h"
#import "UIView+Chat.h"
#import "UITextField+Chat.h"
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

NSString *const NAME_HINT = @"Must be in a range from 3 to 20 characters.";
NSString *const NAME_REGEX = @"^[^_]{3,19}$";

@interface EnterChatNameVC () <UITextFieldDelegate>
//MARK: - Properties
@property (weak, nonatomic) IBOutlet UITextField *chatNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *chatNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic, strong) ChatManager *chatManager;

@end

@implementation EnterChatNameVC
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleView = [[TitleView alloc] init];
    self.navigationItem.titleView = self.titleView;
    [self setupNavigationTitle];
    
    self.chatManager = [ChatManager instance];
    

    self.tableView.estimatedRowHeight = 102.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.delaysContentTouches = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
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
    [self.chatNameTextField becomeFirstResponder];
    self.hintLabel.text = @"";
    [self.chatNameTextField setPadding:12.0f isLeft:YES];
    [self.chatNameTextField addShadowToTextFieldWithColor:[UIColor colorWithRed:0.88f green:0.92f blue:1.0f alpha:1.0f] cornerRadius:4.0f];
    self.chatNameTextField.text = @"";
    [self validateTextField:self.chatNameTextField];
}

- (void)setupNavigationTitle {
    NSString *title = @"New Chat";
    NSString *numberUsers = [NSString stringWithFormat:@"%@ users selected", @(self.selectedUsers.count)];
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

#pragma mark - Actions
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

- (IBAction)createChatButtonPressed:(UIButton *)sender {
    if (Reachability.instance.networkStatus == NetworkStatusNotReachable) {
        [self showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                         message:NSLocalizedString(@"Make sure your device is connected to the internet", nil)
              fromViewController:self];
        [SVProgressHUD dismiss];
        return;
    }
    if (self.selectedUsers.count > 1) {
        // Creating private chat.
        [SVProgressHUD show];
        [self.chatManager.storage updateUsers:self.selectedUsers];
        
        NSString *chatName = self.chatNameTextField.text;
        
        [self.chatManager createGroupDialogWithName:chatName occupants:self.selectedUsers completion:^(QBResponse * _Nullable response, QBChatDialog * _Nullable createdDialog) {
            if (response.error) {
                [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
                return;
            }
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"STR_DIALOG_CREATED", nil)];
            NSString *message = [self systemMessageWithChatName:chatName];
            
            [self.chatManager sendAddingMessage:message action:DialogActionTypeCreate withUsers:createdDialog.occupantIDs toDialog:createdDialog completion:^(NSError * _Nullable error) {
                [self openNewDialog:createdDialog];
            }];
        }];
    }
}

- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chatNameDidChanged:(UITextField *)sender {
    [self validateTextField:sender];
}

#pragma mark - Helpers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_CHAT", nil)]) {
        ChatViewController *chatController = [segue destinationViewController];
        chatController.dialogID = sender;
    }
}

- (NSString *)systemMessageWithChatName:(NSString *)chatName {
    NSString *actionMessage = NSLocalizedString(@"SA_STR_CREATE_NEW", nil);
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return @"";
    }
    NSString *message = [NSString stringWithFormat:@"%@ %@ \"%@\"", currentUser.fullName, actionMessage, chatName];
    return message;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.hintLabel.text.length && indexPath.row == 1) {
        return 6;
    }
    
    return UITableViewAutomaticDimension;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self validateTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Validation helpers
- (BOOL)isValidChatName:(NSString *)name {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *chatName = [name stringByTrimmingCharactersInSet:characterSet];
    NSString *chatNameRegex = NAME_REGEX;
    NSPredicate *chatNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chatNameRegex];
    BOOL chatNameIsValid = [chatNamePredicate evaluateWithObject:chatName];
    
    return chatNameIsValid;
}

- (void)validateTextField:(UITextField *)textField {
    if (textField == self.chatNameTextField && [self isValidChatName:self.chatNameTextField.text]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.hintLabel.text = @"";
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.hintLabel.text = NAME_HINT;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
