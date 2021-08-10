//
//  OpponentsMediaViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 19.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "OpponentsMediaViewController.h"
#import "UIColor+Chat.h"

@interface OpponentsMediaViewController() <ChatManagerDelegate, BaseCallViewControllerDelegate>
#pragma mark - Properties
@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) UIBarButtonItem *addUsersItem;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *,CallParticipant *> *participants;
@end

@implementation OpponentsMediaViewController

- (instancetype)initWithDialogID:(NSString *)dialogID users:(NSArray<CallParticipant *> *)users {
    self = [super init];
    if (self) {
        self.dialogID = dialogID;
        self.participants = [NSMutableDictionary dictionary];
        for (CallParticipant *participant in users) {
            self.participants[participant.ID] = participant;
        }
    }
    return self;
}

- (void)isUseSearchBar {
    self.useSearchBar = NO;
}


- (void)setupViewWillAppear {
    self.chatManager.delegate = self;
    self.dialog = [self.chatManager.storage dialogWithID:self.dialogID];

    for (NSNumber *participantID in self.participants.allKeys) {
        QBUUser *qbUser = [self.chatManager.storage userWithID:participantID.unsignedIntValue];
        if (qbUser) {
            [self.users addObject:qbUser];
        }
    }
    [self setupUsers];
    
    self.view.backgroundColor = self.tableView.backgroundColor;
}

- (void)updateWithConnect {}

- (void)setupFetchUsers {}

#pragma mark - Setup
- (void)setupNavigationTitle {
    NSString *title = self.dialog.name;
    NSString *numberUsers = [NSString stringWithFormat:@"%@ in call", @(self.users.count)];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor mainColor];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"navbar-shadow"];
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    [self.titleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

- (void)tableView:(UITableView *)tableView
         configureCell:(UserTableViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    QBUUser *user = self.users[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.muteButton.hidden = NO;
    cell.muteButton.enabled = YES;
    
    if (self.currentUser.ID == user.ID) {
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.name,  @"(You)"];
        cell.muteButton.hidden = YES;
        cell.muteButton.enabled = NO;
    } else {
        cell.userNameLabel.text = user.name;
    }

    cell.checkBoxView.hidden = YES;
    cell.checkBoxImageView.hidden = YES;
    cell.userInteractionEnabled = YES;

    [cell setDidPressMuteButton:^(BOOL isMuted) {
        if (self.didPressMuteUser) {
            self.didPressMuteUser(isMuted, @(user.ID));
        }
    }];
    BOOL isEnabledSound = self.participants[@(user.ID)].isEnabledSound;
    cell.muteButton.selected = !isEnabledSound;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapAddUsers:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"goToAddOpponents" sender:nil];
}

- (void)checkCreateChatButtonState {}

#pragma mark - Internal Methods

- (void)setupUsers {
    [self setupNavigationTitle];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

#pragma mark Chat Manager Delegate
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
    [self setupUsers];
}

- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager {

}

- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    if (![chatDialog.ID isEqualToString: self.dialogID]) {
        return;
    }
    [self setupUsers];
}

- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

#pragma mark BaseCallViewControllerDelegate
- (void)callVCdidAdd:(BOOL)isAdded NewPublisher:(NSNumber *)userID {
    
    __weak __typeof(self) weakSelf = self;
    
    void(^handlerAddedUser)(QBUUser *addedUser) = ^(QBUUser *addedUser) {
        if (isAdded) {
            [weakSelf.users insertObject:addedUser atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
        } else {
            if (![weakSelf.users containsObject:addedUser]) {
                return;
            }
            NSInteger index = [weakSelf.users indexOfObject:addedUser];
            [weakSelf.users removeObject:addedUser];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
        }
    };
    
    QBUUser *addedUser = [self.chatManager.storage userWithID:userID.unsignedIntValue];
    if (!addedUser) {
        [self.chatManager loadUserWithID:userID.unsignedIntValue completion:^(QBUUser * _Nullable user) {
            handlerAddedUser(user);
        }];
    } else {
        handlerAddedUser(addedUser);
    }
}

@end
