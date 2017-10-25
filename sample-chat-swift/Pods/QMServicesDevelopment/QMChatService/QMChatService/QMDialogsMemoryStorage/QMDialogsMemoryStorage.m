//
//  QMDialogsMemoryStorage.m
//  QMServices
//
//  Created by Andrey on 03.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDialogsMemoryStorage.h"
#import "QBChatMessage+QMCustomParameters.h"

@interface QMDialogsMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *dialogs;
@property (strong, nonatomic) NSMutableArray *blocks;

@end

@implementation QMDialogsMemoryStorage

- (void)dealloc {
    
    [self.dialogs removeAllObjects];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _dialogs = [NSMutableDictionary dictionary];
    }
    return self;
}

//MARK: - Add / Join / Remove

static inline void
updateDialog(QBChatDialog *src, QBChatDialog *res) {
    
    //'updatedAt' and 'unreadMessagesCount' values stored in
    //the 'src' dialog should be updated only with later actual values
    if ([src.updatedAt compare:res.updatedAt] == NSOrderedAscending) {
        src.updatedAt = res.updatedAt;
        src.unreadMessagesCount = res.unreadMessagesCount;
    }
    
    src.createdAt = res.createdAt;
    src.name = res.name;
    src.photo = res.photo;
    src.lastMessageDate = res.lastMessageDate;
    src.lastMessageUserID = res.lastMessageUserID;
    src.lastMessageText = res.lastMessageText;
    src.occupantIDs = res.occupantIDs;
    src.data = res.data;
    src.userID = res.userID;
}

- (void)addChatDialog:(QBChatDialog *)chatDialog
              andJoin:(BOOL)join
           completion:(void(^)(QBChatDialog *dialog, NSError *error))completion {
    
    NSAssert(chatDialog != nil, @"Chat dialog is nil!");
    NSAssert(chatDialog.ID != nil, @"Chat dialog without identifier!");
    
    QBChatDialog *localDialog = self.dialogs[chatDialog.ID];
    
    if (localDialog != nil) {
        updateDialog(localDialog, chatDialog);
    }
    else {
        self.dialogs[chatDialog.ID] = chatDialog;
    }
    
    NSAssert(chatDialog.type != 0, @"Chat type is not defined");
    
    if (chatDialog.type != QBChatDialogTypePrivate && !chatDialog.isJoined && join) {
        
        [chatDialog joinWithCompletionBlock:^(NSError *error) {
            
            if (completion) {
                completion(chatDialog, error);
            }
        }];
    }
    else {
        
        if (completion) {
            completion(chatDialog, nil);
        }
    }
}

- (void)addChatDialogs:(NSArray *)dialogs andJoin:(BOOL)join {
    
    for (QBChatDialog *chatDialog in dialogs) {
        
        [self addChatDialog:chatDialog andJoin:join completion:nil];
    }
}

- (void)deleteChatDialogWithID:(NSString *)chatDialogID {
    
    [self.dialogs removeObjectForKey:chatDialogID];
}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    
    return self.dialogs[dialogID];
}

- (QBChatDialog *)privateChatDialogWithOpponentID:(NSUInteger)opponentID {
    
    NSArray *allDialogs = [self unsortedDialogs];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"SELF.type == %d AND SUBQUERY(SELF.occupantIDs, $userID, $userID == %@).@count > 0",
     QBChatDialogTypePrivate, @(opponentID)];
    
    NSArray *result = [allDialogs filteredArrayUsingPredicate:predicate];
    QBChatDialog *dialog = result.firstObject;
    
    return dialog;
}

- (NSArray *)chatDialogsWithUsersIDs:(NSArray *)usersIDs {
    
    NSArray *dialogs = [self.dialogs allValues];
    
    NSMutableArray *result = [NSMutableArray array];
    NSSet *usersIDsSet = [NSSet setWithArray:usersIDs];
    
    for (QBChatDialog *dialog in dialogs) {
        
        NSMutableSet *occupantIDs = [NSMutableSet setWithArray:dialog.occupantIDs];
        if ([occupantIDs intersectsSet:usersIDsSet]) {
            
            [result addObject:dialog];
        }
    }
    
    return result.copy;
}

- (NSArray *)unsortedDialogs {
    
    NSArray *dialogs = [self.dialogs allValues];
    
    return dialogs;
}

//MARK: - Dialogs toos

- (NSArray *)unreadDialogs {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unreadMessagesCount > 0"];
    NSArray *result = [self.dialogs.allValues filteredArrayUsingPredicate:predicate];
    
    return result;
}

- (NSArray *)dialogsSortByLastMessageDateWithAscending:(BOOL)ascending {
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:ascending];
    
    return [self dialogsWithSortDescriptors:@[sort]];
};

- (NSArray *)dialogsSortByUpdatedAtWithAscending:(BOOL)ascending {
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:ascending];
    
    return [self dialogsWithSortDescriptors:@[sort]];
};

- (NSArray *)dialogsWithSortDescriptors:(NSArray *)descriptors {
    
    NSArray *sortedDialogs = [self.dialogs.allValues sortedArrayUsingDescriptors:descriptors];
    
    return sortedDialogs;
}

//MARK: - QMMemoryStorageProtocol

- (void)free {
    
    [self.dialogs removeAllObjects];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@ %p> dialogs: %tu",
            NSStringFromClass(self.class), self, _dialogs.count];
}

@end
