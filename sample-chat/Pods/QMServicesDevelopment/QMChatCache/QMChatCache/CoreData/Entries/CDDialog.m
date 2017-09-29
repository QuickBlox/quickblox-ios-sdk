#import "CDDialog.h"

@implementation CDDialog

- (QBChatDialog *)toQBChatDialog {
    
    QBChatDialog *dialog =
    [[QBChatDialog alloc] initWithDialogID:self.dialogID
                                      type:self.dialogType.intValue];
    
    dialog.createdAt = self.createdAt;
    dialog.name = self.name;
    dialog.photo = self.photo;
    dialog.lastMessageText = self.lastMessageText;
    dialog.lastMessageDate = self.lastMessageDate;
    dialog.updatedAt = self.updatedAt;
    dialog.lastMessageUserID = self.lastMessageUserIDValue;
    dialog.unreadMessagesCount = self.unreadMessagesCountValue;
    dialog.occupantIDs = self.occupantsIDs;
    dialog.userID = self.userIDValue;
    dialog.data = self.data;

    return dialog;
}

- (void)updateWithQBChatDialog:(QBChatDialog *)dialog {
    
    NSAssert(dialog.type != 0, @"dialog type is undefined");
    
    self.dialogID = dialog.ID;
    self.dialogTypeValue = dialog.type;
    self.name = dialog.name;
    self.photo = dialog.photo;
    self.lastMessageText = dialog.lastMessageText;
    self.lastMessageDate = dialog.lastMessageDate;
    self.updatedAt = dialog.updatedAt;
    self.lastMessageUserIDValue = (int32_t)dialog.lastMessageUserID;
    self.unreadMessagesCountValue = (int32_t)dialog.unreadMessagesCount;
    self.occupantsIDs = dialog.occupantIDs;
    self.userIDValue = (int32_t)dialog.userID;
    self.data = dialog.data;
}

@end

@implementation NSArray(CDDialog)

- (NSArray<QBChatDialog *> *)toQBChatDialogs  {
    
    NSMutableArray<QBChatDialog *> *result =
    [NSMutableArray arrayWithCapacity:self.count];
    
    for (CDDialog *cache in self) {
        
        QBChatDialog *dialog = [cache toQBChatDialog];
        [result addObject:dialog];
    }
    
    return [result copy];
}

@end
