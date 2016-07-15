//
//  DialogInfoTableViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "DialogInfoTableViewController.h"
#import "UsersDataSource.h"
#import "ServicesManager.h"
#import "UserTableViewCell.h"

@interface DialogInfoTableViewController() <QMChatServiceDelegate, QMChatConnectionDelegate>

@property (nonatomic, strong) UsersDataSource *usersDatasource;
@property (nonatomic, assign, getter=isEditMode) BOOL editMode;
@property (nonatomic, weak) IBOutlet UIButton *btnEdit;

@end

@implementation DialogInfoTableViewController

- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsSelection = false;
    
    self.title = NSLocalizedString(@"SA_STR_CHAT_INFO", nil);
    
    [self refreshDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ServicesManager instance].chatService addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ServicesManager instance].chatService removeDelegate:self];
}


#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateEditButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateEditButtonState];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if([self.dialog.ID isEqualToString:chatDialog.ID]) {
        self.dialog = chatDialog;
        [self refreshDataSource];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray *)dialogs {
    
    if ([dialogs containsObject:self.dialog]) {
        
        NSUInteger index = [dialogs indexOfObject:self.dialog];
        self.dialog = dialogs[index];
        [self refreshDataSource];
    }
}

- (IBAction)rightNavBarItemAction:(id)sender {
    
    NSArray *indexPathArray = [self.tableView indexPathsForSelectedRows];
    
    if (indexPathArray.count) {
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:indexPathArray.count];
        NSMutableArray *usersIDs = [NSMutableArray arrayWithCapacity:indexPathArray.count];
        
        for (NSIndexPath *indexPath in indexPathArray) {
            UserTableViewCell *selectedCell = (UserTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
            [users addObject:selectedCell.user];
            [usersIDs addObject:@(selectedCell.user.ID)];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        __weak __typeof(self)weakSelf = self;
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
        return;
    }
    
    self.editMode ^=1;
    [self updateEditButtonState];
    
    self.tableView.allowsMultipleSelection = self.isEditMode;
    self.usersDatasource.editMode = self.isEditMode;
    [self.tableView reloadData];
}
#pragma mark - Helpers

- (void)refreshDataSource {
    __weak __typeof(self) weakSelf = self;
    
    // Retrieving users from cache.
    [[[ServicesManager instance].usersService getUsersWithIDs:self.dialog.occupantIDs] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.usersDatasource = [[UsersDataSource alloc] initWithUsers:task.result];
        strongSelf.usersDatasource.editMode = self.isEditMode;
        
        strongSelf.tableView.dataSource = strongSelf.usersDatasource;
        
        [strongSelf.tableView reloadData];
        
        return nil;
    }];
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
            
            
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                __typeof(self) strongSelf = weakSelf;
                if (strongSelf.didDismissWithDialog) {
                    strongSelf.didDismissWithDialog(createdDialog);
                }
            }];
            
            
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
                                                                                      
                                                                                      [strongSelf dismissViewControllerAnimated:YES completion:nil];
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

- (void)updateEditButtonState {
    
    NSString * title = @"";
    
    if (self.isEditMode) {
        title = self.tableView.indexPathsForSelectedRows.count ? @"Done" : @"Cancel";
    }
    else {
        title = @"Edit";
    }

    [self.btnEdit setTitle:title forState:UIControlStateNormal];
}

@end
