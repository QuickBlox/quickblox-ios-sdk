
#import "_CDAttachment.h"

@interface CDAttachment : _CDAttachment {}

- (QBChatAttachment *)toQBChatAttachment;
- (void)updateWithQBChatAttachment:(QBChatAttachment *)attachment;

@end
