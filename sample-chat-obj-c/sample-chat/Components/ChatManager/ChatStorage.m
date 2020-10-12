//
//  ChatStorage.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatStorage.h"
#import "Log.h"

@implementation ChatStorage

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dialogs = [NSMutableArray array];
        self.users = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods
- (void)clear {
    [self.dialogs removeAllObjects];
    [self.users removeAllObjects];
}

- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID {
    for (QBChatDialog *dialog in self.dialogs) {
        if (dialog.type == QBChatDialogTypePrivate && ([dialog.occupantIDs containsObject:@(opponentID)])) {
            return dialog;
        }
    }
    return nil;
}

- (QBChatDialog *)dialogWithID:(NSString *)dialogID {
    NSPredicate *predicateDialog = [NSPredicate predicateWithFormat:@"ID == %@", dialogID];
    QBChatDialog *localDialog = [[self.dialogs filteredArrayUsingPredicate:predicateDialog] firstObject];
    if (localDialog) {
        return localDialog;
    }
    return nil;
}

- (NSArray<QBChatDialog*> *)dialogsSortByUpdatedAt {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
    NSArray *sortedDialogs = [self.dialogs sortedArrayUsingDescriptors:@[sort]];
    return sortedDialogs;
}

- (void)updateDialogs:(NSArray<QBChatDialog*> *)dialogs {
    for (QBChatDialog *chatDialog in dialogs) {
        NSAssert(chatDialog.type != 0, @"Chat type is not defined");
        NSAssert(chatDialog.ID != nil, @"Chat ID is not defined");
        
        QBChatDialog *dialog = [self updateDialog:chatDialog];
        
        // Autojoin to the group chat
        if (dialog.type != QBChatDialogTypePrivate && dialog.isJoined == NO) {
            [dialog joinWithCompletionBlock:^(NSError *error) {
                if (error) {
                    Log(@"[%@] updateDialogs error: %@",
                        NSStringFromClass([ChatStorage class]),
                        error.localizedDescription);
                }
            }];
        }
    }
}

- (void)deleteDialogWithID:(NSString *)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", ID];
    QBChatDialog *localDialog = [[self.dialogs filteredArrayUsingPredicate:predicate] firstObject];
    [self.dialogs removeObject:localDialog];
}

- (QBUUser *)userWithID:(NSUInteger)ID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", @(ID)];
    QBUUser *user = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    return user;
}

- (void)updateUsers:(NSArray<QBUUser *> *)users {
    for (QBUUser *chatUser in users) {
        [self updateUser:chatUser];
    }
}

- (NSArray<QBUUser*> *)usersWithDialogID:(NSString *)dialogID {
    NSMutableArray<QBUUser *> *users = [NSMutableArray array];

    QBChatDialog *localDialog = [self dialogWithID:dialogID];
    if (localDialog) {
        for (NSNumber * ID in localDialog.occupantIDs) {
            NSPredicate *predicateUser = [NSPredicate predicateWithFormat:@"ID == %@", ID];
            QBUUser *user = [[self.users filteredArrayUsingPredicate:predicateUser] firstObject];
            if (user) {
                [users addObject:user];
            }
        }
    }
    return  [self sortedUsers:users.copy];
}

- (NSArray<QBUUser*> *)sortedAllUsers {
    NSSortDescriptor *usersSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastRequestAt" ascending:NO];
    NSArray *sortedUsers = [self.users sortedArrayUsingDescriptors:@[usersSortDescriptor]];
    
    return sortedUsers;
}

#pragma mark - Internal Methods
- (void)markMessagesAsDeliveredForDialogID:(NSString *)dialogID {
    [QBRequest markMessagesAsDelivered:nil dialogID:dialogID successBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] dialog.markMessages as Delivered success!!!",
            NSStringFromClass([ChatStorage class]));
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"[%@] dialog.markMessages as Delivered error: %@",
            NSStringFromClass([ChatStorage class]),
            response.error.error.localizedDescription);
    }];
}

- (QBChatDialog *)updateDialog:(QBChatDialog *)dialog {
    NSAssert(dialog.type != 0, @"Chat type is not defined");
    
    QBChatDialog *localDialog = [self dialogWithID:dialog.ID];
    
    if (localDialog) {
        localDialog.updatedAt = dialog.updatedAt;
        localDialog.createdAt = dialog.createdAt;
        localDialog.name = dialog.name;
        localDialog.photo = dialog.photo;
        localDialog.lastMessageDate = dialog.lastMessageDate;
        localDialog.lastMessageUserID = dialog.lastMessageUserID;
        localDialog.lastMessageText = dialog.lastMessageText;
        localDialog.occupantIDs = dialog.occupantIDs;
        localDialog.data = dialog.data;
        localDialog.userID = dialog.userID;
        localDialog.unreadMessagesCount = dialog.unreadMessagesCount;
        return localDialog;
    }
    [self.dialogs addObject:dialog];
    return dialog;
}

- (NSArray<QBUUser*> *)sortedUsers:(NSArray<QBUUser*> *)users {
    NSSortDescriptor *usersSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastRequestAt" ascending:NO];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[usersSortDescriptor]];
    
    return sortedUsers;
}

- (void)updateUser:(QBUUser *)user {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", @(user.ID)];
    QBUUser *localUser = [[self.users filteredArrayUsingPredicate:predicate] firstObject];
    if (localUser) {
        //Update local User
        localUser.fullName = user.fullName;
        localUser.lastRequestAt = user.lastRequestAt;
        return;
    }
    [self.users addObject:user];
}

@end
