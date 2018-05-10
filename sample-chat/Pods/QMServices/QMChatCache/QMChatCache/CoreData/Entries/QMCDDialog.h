#import "_QMCDDialog.h"

@interface QMCDDialog : _QMCDDialog {}

- (QBChatDialog *)toQBChatDialog;
- (void)updateWithQBChatDialog:(QBChatDialog *)dialog;

@end

@interface NSArray(QMCDDialog)

- (NSArray<QBChatDialog *> *)toQBChatDialogs;

@end
