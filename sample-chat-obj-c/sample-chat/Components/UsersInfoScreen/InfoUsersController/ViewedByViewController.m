//
//  ViewedByViewController.m
//  sample-chat
//
//  Created by Injoit on 07.03.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "ViewedByViewController.h"
#import "TitleView.h"
#import "Profile.h"
#import "ChatManager.h"
#import "QBUUser+Chat.h"
#import "UIViewController+Alert.h"
#import "Log.h"

NSString *const DELIVERED = @"Message delivered to";
NSString *const VIEWED = @"Message viewed by";

@interface ViewedByViewController () <QBChatDelegate>
@property (nonatomic, strong) QBChatMessage *message;
@property (strong, nonatomic) TitleView *navigationTitleView;
@property (nonatomic, strong) ChatManager *chatManager;
@end

@implementation ViewedByViewController
- (void)setMessageID:(NSString *)messageID {
    _messageID = messageID;
    [self setupMessage];
}

- (void)setMessage:(QBChatMessage *)message {
    _message = message;
    [self setupUsers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = nil;
    [QBChat.instance addDelegate:self];
    self.chatManager = [ChatManager instance];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    self.navigationTitleView = [[TitleView alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = self.navigationTitleView;
    [self setupNavigationTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (QBChat.instance.isConnected == NO) {
        [self showNoInternetAlertWithHandler:nil];
        return;
    }
}

#pragma mark - Setup
- (void)setupMessage {
    __weak __typeof(self)weakSelf = self;
    [ChatManager.instance messagesWithDialogID:self.dialogID extendedRequest:@{@"_id": self.messageID} skip:0 limit:1 success:^(NSArray<QBChatMessage *> * _Nonnull messages, Boolean isLast) {
        QBChatMessage *downloadedMessage = messages.firstObject;
        if (!downloadedMessage) {
            return;
        }
        weakSelf.message = downloadedMessage;
    } errorHandler:^(NSString * _Nullable error) {
        Log(@"[%@] setupMessage - Error: %@",  NSStringFromClass([ViewedByViewController class]), error);
    }];
}

- (void)setupNavigationTitle {
    NSString *title = self.action == ChatActionViewedBy ? VIEWED : DELIVERED;
    NSString *numberUsers = [NSString stringWithFormat:@"%@ members", @(self.userList.fetched.count)];
    [self.navigationTitleView setupTitleViewWithTitle:title subTitle:numberUsers];
}

- (void)setupUsers {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID != %@", @(self.profile.ID)];
    if (self.action == ChatActionViewedBy) {
        NSArray<QBUUser *> *participants = [self.chatManager.storage usersWithIDs:self.message.readIDs];
        participants = [participants filteredArrayUsingPredicate:predicate];
        if (participants.count) {
            self.userList.fetched = participants.mutableCopy;
        }
    } else if (self.action == ChatActionDeliveredTo) {
        NSArray<QBUUser *> *participants = [self.chatManager.storage usersWithIDs:self.message.deliveredIDs];
        participants = [participants filteredArrayUsingPredicate:predicate];
        if (participants.count) {
            self.userList.fetched = participants.mutableCopy;
        }
    }
    [self.tableView reloadData];
    [self setupNavigationTitle];
}

- (void)tableView:(UITableView *)tableView
    configureCell:(UserTableViewCell *)cell
     forIndexPath:(NSIndexPath *)indexPath {
    cell.checkBoxView.hidden = YES;
    cell.checkBoxImageView.hidden = YES;
    cell.userInteractionEnabled = NO;
}

#pragma mark - Actions
- (void)didTapBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - QBChatDelegate
- (void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID {
    if (self.profile.ID == readerID
        || self.action != ChatActionViewedBy
        || ![self.message.ID isEqualToString:messageID]) {
        return;
    }
    QBChatMessage *readedMessage = [self.dataSource messageWithID:messageID];
    if (readedMessage) {
        NSMutableArray *readIDs = [readedMessage.readIDs mutableCopy];
        if ([readIDs containsObject:@(readerID)]) {
            return;
        }
        [readIDs addObject:@(readerID)];
        [readedMessage setReadIDs: [readIDs copy]];
        [self.dataSource updateMessage:readedMessage];
        
        self.message = readedMessage;
        [self setupUsers];
    }
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID {
    if (self.profile.ID == userID
        || self.action != ChatActionDeliveredTo
        || ![self.message.ID isEqualToString:messageID]) {
        return;
    }
    QBChatMessage *deliveredMessage = [self.dataSource messageWithID:messageID];
    if (deliveredMessage) {
        NSMutableArray *deliveredIDs = [deliveredMessage.deliveredIDs mutableCopy];
        if ([deliveredIDs containsObject:@(userID)]) {
            return;
        }
        [deliveredIDs addObject:@(userID)];
        [deliveredMessage setDeliveredIDs: [deliveredIDs copy]];
        [self.dataSource updateMessage:deliveredMessage];
        
        self.message = deliveredMessage;
        [self setupUsers];
    }
}

- (void)chatDidConnect {
    [self setupMessage];
}

- (void)chatDidReconnect {
    [self setupMessage];;
}

@end
