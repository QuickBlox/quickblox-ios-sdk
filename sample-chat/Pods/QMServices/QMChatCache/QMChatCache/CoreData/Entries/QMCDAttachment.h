
#import "_QMCDAttachment.h"

@interface QMCDAttachment : _QMCDAttachment {}

- (QBChatAttachment *)toQBChatAttachment;
- (void)updateWithQBChatAttachment:(QBChatAttachment *)attachment;

@end
