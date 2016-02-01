#import "CDDialog.h"

@interface CDDialog ()

@end

@implementation CDDialog

- (QBChatDialog *)toQBChatDialog {
    
    QBChatDialog *dialog = [[QBChatDialog alloc] initWithDialogID:self.dialogID type:self.dialogType.intValue];
    
    dialog.name = self.name;
    dialog.photo = self.photo;
    dialog.lastMessageText = self.lastMessageText;
    dialog.lastMessageDate = self.lastMessageDate;
    dialog.updatedAt = self.updatedAt;
    dialog.lastMessageUserID = self.lastMessageUserID.integerValue;
    dialog.unreadMessagesCount = self.unreadMessagesCount.integerValue;
    dialog.occupantIDs = self.occupantsIDs;
    dialog.userID = self.userID.unsignedIntegerValue;
    
    return dialog;
}

- (void)updateWithQBChatDialog:(QBChatDialog *)dialog {
	NSAssert(dialog.type != 0, @"dialog type is undefined");
	
    self.dialogID = dialog.ID;
    self.dialogType = @(dialog.type);
    self.name = dialog.name;
    self.photo = dialog.photo;
    self.lastMessageText = dialog.lastMessageText;
    self.lastMessageDate = dialog.lastMessageDate;
    self.updatedAt = dialog.updatedAt;
    self.lastMessageUserID = @(dialog.lastMessageUserID);
    self.unreadMessagesCount = @(dialog.unreadMessagesCount);
    self.occupantsIDs = dialog.occupantIDs;
    self.userID = @(dialog.userID);
}

@end