#import "_CDDialog.h"

@interface CDDialog : _CDDialog {}

- (QBChatDialog *)toQBChatDialog;
- (void)updateWithQBChatDialog:(QBChatDialog *)dialog;

@end
