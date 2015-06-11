#import "QBXMPPMessage.h"

@interface QBXMPPMessage(XEP0333)

- (BOOL)hasChatMarker;

- (BOOL)hasMarkableChatMarker;
- (BOOL)hasReceivedChatMarker;
- (BOOL)hasDisplayedChatMarker;
- (BOOL)hasAcknowledgedChatMarker;

- (NSString *)chatMarker;
- (NSString *)chatMarkerID;

- (void)addMarkableChatMarker;
- (void)addReceivedChatMarkerWithID:(NSString *)elementID;
- (void)addDisplayedChatMarkerWithID:(NSString *)elementID;
- (void)addAcknowledgedChatMarkerWithID:(NSString *)elementID;

- (QBXMPPMessage *)generateReceivedChatMarker;
- (QBXMPPMessage *)generateDisplayedChatMarker;
- (QBXMPPMessage *)generateAcknowledgedChatMarker;

/// Methods below works as methods above, there is no threading support
- (QBXMPPMessage *)generateReceivedChatMarkerIncludingThread:(BOOL)includingThread;
- (QBXMPPMessage *)generateDisplayedChatMarkerIncludingThread:(BOOL)includingThread;
- (QBXMPPMessage *)generateAcknowledgedChatMarkerIncludingThread:(BOOL)includingThread;

@end