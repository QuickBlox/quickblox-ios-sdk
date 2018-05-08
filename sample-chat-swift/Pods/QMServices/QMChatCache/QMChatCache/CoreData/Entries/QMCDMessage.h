#import "_QMCDMessage.h"
#import <Quickblox/QBChatMessage.h>

@interface QMCDMessage : _QMCDMessage

- (QBChatMessage *)toQBChatMessage;
- (void)updateWithQBChatMessage:(QBChatMessage *)message;

@end

@interface NSArray(QMCDMessage)

- (NSArray<QBChatMessage *> *)toQBChatMessages;

@end
