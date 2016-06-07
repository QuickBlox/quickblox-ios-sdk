//
//  EditDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "EditDialogTableViewController.h"
#import "UsersDataSource.h"
#import "ServicesManager.h"
#import "UserTableViewCell.h"
#import "ChatViewController.h"
#import "DialogsViewController.h"

@interface EditDialogTableViewController() <QMChatServiceDelegate, QMChatConnectionDelegate>
@property (nonatomic, strong) UsersDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnSave;
@end

@implementation EditDialogTableViewController

#pragma mark - View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    NSParameterAssert(self.dialog);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDataSource];
    [ServicesManager.instance.chatService addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ServicesManager.instance.chatService removeDelegate:self];
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSaveButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSaveButtonState];
}

#pragma mark - IBActions
- (IBAction)saveButtonTapped:(id)sender {
    NSArray *indexPathArray = [self.tableView indexPathsForSelectedRows];
    assert(indexPathArray.count != 0);
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:indexPathArray.count];
    NSMutableArray *usersIDs = [NSMutableArray arrayWithCapacity:indexPathArray.count];
    
    for (NSIndexPath *indexPath in indexPathArray) {
        UserTableViewCell *selectedCell = (UserTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        [users addObject:selectedCell.user];
        [usersIDs addObject:@(selectedCell.user.ID)];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    [self updateSaveButtonState];
    
    __weak __typeof(self)weakSelf = self;
    
    [weakSelf updateSaveButtonState];
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        // Retrieving users with identifiers.
        [[[ServicesManager instance].usersService getUsersWithIDs:self.dialog.occupantIDs] continueWithBlock:^id(BFTask *task) {
            
            if (task.error) {
                [SVProgressHUD showErrorWithStatus:task.error.localizedDescription];
                return nil;
            }
            __typeof(self) strongSelf = weakSelf;
            [users addObjectsFromArray:task.result];
            
            [strongSelf createGroupDialogWithUsers:users];
            
            return nil;
        }];
    } else {
        [self updateGroupDialogWithUsersIDs:usersIDs];
    }
}

#pragma mark QMChatServiceDelegate delegate

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    if ([chatDialog.ID isEqualToString:self.dialog.ID]) {
        self.dialog = chatDialog;
        [self reloadDataSource];
    }
}

#pragma mark - Helpers

- (void)reloadDataSource {
    self.dataSource = [[UsersDataSource alloc] init];
    [self.dataSource setExcludeUsersIDs:self.dialog.occupantIDs];
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
    [self updateSaveButtonState];
}
- (void)createGroupDialogWithUsers:(NSArray *)users {
    __weak __typeof(self)weakSelf = self;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING", nil) maskType:SVProgressHUDMaskTypeClear];
    
    // Creating group chat dialog.
   
    
    [ServicesManager.instance.chatService createGroupChatDialogWithName:[self dialogNameFromUsers:users] photo:nil occupants:users completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        __typeof(self) strongSelf = weakSelf;
        
        if (response.success ) {
            
            [SVProgressHUD dismiss];
             NSString *notificationText = [strongSelf updatedMessageWithUsers:users forCreatedDialog:YES];
            
            [[ServicesManager instance].chatService sendSystemMessageAboutAddingToDialog:createdDialog
                                                                              toUsersIDs:createdDialog.occupantIDs
                                                                                withText:notificationText
                                                                              completion:^(NSError *error) {
                
                [[ServicesManager instance].chatService sendNotificationMessageAboutAddingOccupants:createdDialog.occupantIDs
                                                                                           toDialog:createdDialog
                                                                               withNotificationText:notificationText
                                                                                         completion:nil];
                
            }];
            
            [strongSelf navigateToChatViewControllerWithDialog:createdDialog];
        }
        else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SA_STR_CANNOT_CREATE_DIALOG", nil)];
            NSLog(@"can not create dialog: %@", response.error.error);
        }
    }];
}

- (void)updateGroupDialogWithUsersIDs:(NSArray *)usersIDs {
    __weak __typeof(self)weakSelf = self;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SA_STR_LOADING", nil) maskType:SVProgressHUDMaskTypeClear];
    
    // Retrieving users from cache.
    [[[ServicesManager instance].usersService getUsersWithIDs:usersIDs] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            [SVProgressHUD showErrorWithStatus:task.error.localizedDescription];
            return nil;
        }
        // Updating dialog with occupants.
        [ServicesManager.instance.chatService joinOccupantsWithIDs:usersIDs toChatDialog:self.dialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
            
            __typeof(self) strongSelf = weakSelf;
            if (response.success) {
                
                if (task.error) {
                    [SVProgressHUD showErrorWithStatus:task.error.localizedDescription];
                    return;
                }
                
                NSString *notificationText = [strongSelf updatedMessageWithUsers:task.result forCreatedDialog:NO];
                
                // Notifying users about newly created dialog.
                [[ServicesManager instance].chatService sendSystemMessageAboutAddingToDialog:updatedDialog
                                                                                  toUsersIDs:usersIDs
                                                                                    withText:notificationText
                                                                                  completion:^(NSError *error) {
                    //
                    
                    // Notify occupants that dialog was updated.
                    [[ServicesManager instance].chatService sendNotificationMessageAboutAddingOccupants:usersIDs
                                                                                               toDialog:updatedDialog
                                                                                   withNotificationText:notificationText
                                                                                             completion:nil];
                    updatedDialog.lastMessageText = notificationText;
                    
                    [strongSelf navigateToChatViewControllerWithDialog:updatedDialog];
                    [SVProgressHUD dismiss];
                }];
            }
        }];
        
        return nil;
    }];
}

- (NSString *)dialogNameFromUsers:(NSArray *)users {
    NSString *name = [NSString stringWithFormat:@"%@_", [QBSession currentSession].currentUser.login];
    for (QBUUser *user in users) {
        name = [NSString stringWithFormat:@"%@%@,", name, user.login];
    }
    name = [name substringToIndex:name.length - 1]; // remove last , (comma)
    return name;
}

- (NSString *)updatedMessageWithUsers:(NSArray *)users forCreatedDialog:(BOOL)isForCreated {
    
    NSString *message = [NSString stringWithFormat:@"%@ %@ ", [ServicesManager instance].currentUser.login, isForCreated ? NSLocalizedString(@"SA_STR_CREATE_NEW", nil) : NSLocalizedString(@"SA_STR_ADDED", nil)];
    
    for (QBUUser *user in users) {
        message = [NSString stringWithFormat:@"%@%@,", message, user.login];
    }
    message = [message substringToIndex:message.length - 1]; // remove last , (comma)
    
    return message;
}

- (void)updateSaveButtonState {
    self.btnSave.enabled = [[self.tableView indexPathsForSelectedRows] count] != 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToChatSegueIdentifier]) {
        ChatViewController *vc = (ChatViewController *) segue.destinationViewController;
        vc.dialog = sender;
    }
}

- (void)navigateToChatViewControllerWithDialog:(QBChatDialog *)dialog {
    
    NSMutableArray *newStack = [NSMutableArray array];

    //change stack by replacing view controllers after ChatVC with ChatVC
    for (UIViewController * vc in self.navigationController.viewControllers) {
        [newStack addObject:vc];
        
        if ([vc isKindOfClass:[DialogsViewController class]]) {
            
            ChatViewController * chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatVC.dialog = dialog;
            
            [newStack addObject:chatVC];
            [self.navigationController setViewControllers:newStack animated:true];
            
            return;
        }
    }
    
    [self performSegueWithIdentifier:kGoToChatSegueIdentifier sender:dialog];
}
@end
