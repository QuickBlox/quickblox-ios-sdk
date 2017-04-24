#import "_CDMessage.h"

@interface CDMessage : _CDMessage

- (QBChatMessage *)toQBChatMessage;
- (void)updateWithQBChatMessage:(QBChatMessage *)message;

@end

@interface NSArray(CDMessage)

- (NSArray<QBChatMessage *> *)toQBChatMessages;

@end
