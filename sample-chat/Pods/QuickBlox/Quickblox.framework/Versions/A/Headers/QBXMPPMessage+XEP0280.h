#import "QBXMPPMessage.h"

@class QBXMPPJID;

@interface QBXMPPMessage(XEP0280)

- (QBXMPPMessage *)receivedMessageCarbon;
- (QBXMPPMessage *)sentMessageCarbon;

- (BOOL)isMessageCarbon;
- (BOOL)isReceivedMessageCarbon;
- (BOOL)isSentMessageCarbon;
- (BOOL)isTrustedMessageCarbon;
- (BOOL)isTrustedMessageCarbonForMyJID:(QBXMPPJID *)jid;

- (QBXMPPMessage *)messageCarbonForwardedMessage;

- (void)addPrivateMessageCarbons;

@end