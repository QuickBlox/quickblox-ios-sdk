#import <Foundation/Foundation.h>
#import "QBXMPPMessage.h"


@interface QBXMPPMessage(XEP0045)

- (BOOL)isGroupChatMessage;
- (BOOL)isGroupChatMessageWithBody;

@end
