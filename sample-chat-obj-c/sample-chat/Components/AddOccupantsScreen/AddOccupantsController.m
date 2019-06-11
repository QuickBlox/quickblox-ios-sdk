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

@interface AddOccupantsController () <ChatManagerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSArray<QBUUser *> *users;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *oldDialogUsers;
@property (nonatomic, strong) NSMutableSet<QBUUser *> *selectedUsers;
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) UITextField *chatNameTextFeld;
@property (nonatomic, strong) UIAlertAction *successAction;
@end

@implementation AddOccupantsController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatManager = [ChatManager instance];
    self.chatManager.delegate = self;
    
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];
    if (self.dialog.occupantIDs.count >= self.chatManager.storage.users.count) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    self.oldDialogUsers = [NSMutableArray array];
    self.selectedUsers = [NSMutableSet set];
    
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull) {
        self.navigationItem.title = currentUser.fullName;
    }
    
    if ([QBChat.instance isConnected]) {
        [self.chatManager updateStorage];
    }
    
    [self checkCreateChatButtonState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"SA_STR_DONE", nil);
    self.title = NSLocalizedString(@"SA_STR_ADD_OCCUPANTS", nil);
}

#pragma mark - Internal Methods
- (void)updateUsers {
    NSArray<QBUUser *> *users = self.chatManager.storage.sortedAllUsers;
    [self setupUsers:users];
    [self checkCreateChatButtonState];
}

- (void)setupUsers:(NSArray <QBUUser *> *)users {
    NSMutableArray<QBUUser *> *filteredUsers = [NSMutableArray array];
    [self.oldDialogUsers removeAllObjects];
    self.users = @[];
    
    Profile *currentUser = [[Profile alloc] init];
    
    for (QBUUser *user in users) {
        if (user.ID == currentUser.ID) {
            continue;
        }
        
        if ([self.dialog.occupantIDs containsObject:@(user.ID)]) {
            [self.oldDialogUsers addObject:user];
        } else {
            [filteredUsers addObject:user];
        }
    }
    NSSet *selectedUsers = [NSSet setWithSet:self.selectedUsers];
    for (QBUUser *user in selectedUsers) {
        if ([self.dialog.occupantIDs containsObject:@(user.ID)]) {
            [self.selectedUsers removeObject:user];
        }
    }
    
    self.users = [filteredUsers copy];
    [self checkCreateChatButtonState];
    [self.tableView reloadData];
}

- (void)checkCreateChatButtonState {
    self.navigationItem.rightBarButtonItem.enabled = self.selectedUsers.count > 0;
}

- (NSString *)systemMessageWithAction:(DialogActionType)actionType withUsers:(NSArray<QBUUser *> *)users {
    NSString *actionMessage = actionType == DialogActionTypeCreate ?
    NSLocalizedString(@"SA_STR_CREATE", nil) : NSLocalizedString(@"SA_STR_ADDED", nil);
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

- (void)updateDialog:(QBChatDialog *)dialog withNewUsers:(NSArray<QBUUser *> *)users
      withCompletion:(void(^)(QBResponse *response, QBChatDialog *dialog))completion {
    NSMutableArray *mutUsersIDs = [NSMutableArray array];
    
    for (QBUUser *user in users) {
        [mutUsersIDs addObject:@(user.ID)];
    }
    NSArray *usersIDs = [mutUsersIDs copy];
    // Updates dialog with new occupants.
    [self.chatManager joinOccupantsWithIDs:usersIDs toDialog:dialog completion:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull updatedDialog) {
        if (!updatedDialog || response.error) {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            completion(response, nil);
            return;
        }
        NSString *message = [self systemMessageWithAction:DialogActionTypeAdd withUsers:users];
        
        [self.chatManager sendAddingMessage:message action:DialogActionTypeAdd withUsers:usersIDs toDialog:updatedDialog completion:^(NSError * _Nullable error) {
            if (completion) {
                completion(response, updatedDialog);
            }
        }];
    }];
}

- (void)createChatWithName:(NSString *)name
                     users:(NSArray<QBUUser *> *)users
            withCompletion:(void(^)(QBResponse *response, QBChatDialog *dialog))completion {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    // Creating group chat.
    [self.chatManager createGroupDialogWithName:name occupants:users completion:^(QBResponse * _Nullable response, QBChatDialog * _Nullable dialog) {
        if (response.error) {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
            return;
        }
        NSString *message = [self systemMessageWithAction:DialogActionTypeAdd withUsers:users];
        
        [self.chatManager sendAddingMessage:message action:DialogActionTypeCreate withUsers:dialog.occupantIDs toDialog:dialog completion:^(NSError * _Nullable error) {
            completion(response, dialog);
        }];
    }];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSLocalizedString(@"SA_STR_SEGUE_GO_TO_CHAT", nil)]) {
        ChatViewController *chatController = [segue destinationViewController];
        chatController.dialogID = sender;
    }
}

- (IBAction)createChatButtonPressed:(UIButton *)sender {
    
    NSArray *selectedIndexes = self.tableView.indexPathsForSelectedRows;
    NSMutableArray<QBUUser *> *mutUsers = [NSMutableArray array];
    for (NSIndexPath *indexPath in selectedIndexes) {
        QBUUser *user = self.users[indexPath.row];
        [mutUsers addObject:user];
    }
    
    NSArray *selectedUsers = [mutUsers copy];
    
    void(^completion)(QBResponse *, QBChatDialog *) = ^(QBResponse *response, QBChatDialog *dialog) {
        if (dialog) {
            for (NSIndexPath *indexPath in selectedIndexes) {
                [self.tableView  deselectRowAtIndexPath:indexPath animated:NO];
            }
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"STR_DIALOG_CREATED", nil)];
            [self checkCreateChatButtonState];
            [self openNewDialog:dialog];
        } else {
            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
        }
    };
    
    if (self.dialog.type == QBChatDialogTypeGroup) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self updateDialog:self.dialog withNewUsers:selectedUsers withCompletion:completion];
    } else if (self.dialog.type == QBChatDialogTypePrivate) {
        NSArray *dialogUsers = [selectedUsers arrayByAddingObjectsFromArray:self.oldDialogUsers];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SA_STR_ENTER_CHAT_NAME", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            self.chatNameTextFeld = textField;
            self.chatNameTextFeld.placeholder = @"Enter Chat Name";
            self.chatNameTextFeld.delegate = self;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
        
        self.successAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SA_STR_OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alertController.textFields.firstObject;
            NSString *chatName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [self createChatWithName:chatName users:dialogUsers withCompletion:completion];
        }];
        
        self.successAction.enabled = NO;
        [alertController addAction:cancelAction];
        [alertController addAction:self.successAction];
        [self presentViewController:alertController animated:NO completion:^{
            [self checkCreateChatButtonState];
        }];
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
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSLocalizedString(@"SA_STR_CELL_USER", nil)];
    QBUUser *user = self.users[indexPath.row];
    UIColor *color = [UIColor colorWithIndex:indexPath.row];
    cell.colorMarker.bgColor = color;
    cell.userDescriptionLabel.text = user.name;
    cell.tag = indexPath.row;
    
    if ([self.selectedUsers containsObject:user]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    [self.selectedUsers addObject:user];
    [self checkCreateChatButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    if ([self.selectedUsers containsObject:user]) {
        [self.selectedUsers removeObject:user];
    }
    [self checkCreateChatButtonState];
}

#pragma mark Chat Manager Delegate
- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING_USERS", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
    [self setupUsers:chatManager.storage.sortedAllUsers];
}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if ([chatDialog.ID isEqualToString: self.dialogID]) {
        [self updateUsers];
    }
}

#pragma mark - Validation helpers
- (BOOL)isValidChatName:(NSString *)chatName {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [chatName stringByTrimmingCharactersInSet:characterSet];
    NSString *chatNameRegex = @"^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$";
    NSPredicate *chatNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chatNameRegex];
    BOOL chatNameIsValid = [chatNamePredicate evaluateWithObject:name];
    return chatNameIsValid;
}

- (void)validateTextField:(UITextField *)textField {
    if (textField == self.chatNameTextFeld && [self isValidChatName:self.chatNameTextFeld.text] == NO) {
        self.successAction.enabled = NO;
    } else {
        self.successAction.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self validateTextField:textField];
    return YES;
}

@end
