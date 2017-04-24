#import "_CDDialog.h"

@interface CDDialog : _CDDialog {}

- (QBChatDialog *)toQBChatDialog;
- (void)updateWithQBChatDialog:(QBChatDialog *)dialog;

@end

@interface NSArray(CDDialog)

- (NSArray<QBChatDialog *> *)toQBChatDialogs;

@end
