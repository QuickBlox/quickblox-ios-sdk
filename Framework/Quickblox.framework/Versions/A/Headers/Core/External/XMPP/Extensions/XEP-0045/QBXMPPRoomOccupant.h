//
// XMPPRoomOccupant
// A chat room. XEP-0045 Implementation.
//

#import <Foundation/Foundation.h>

@class QBXMPPJID;

@interface QBXMPPRoomOccupant : NSObject
{
	QBXMPPJID *jid;
	NSString *nick;
	NSString *role;
}

+ (QBXMPPRoomOccupant *)occupantWithJID:(QBXMPPJID *)aJid nick:(NSString *)aNick role:(NSString *)aRole;

- (id)initWithJID:(QBXMPPJID *)aJid nick:(NSString *)aNick role:(NSString *)aRole;

@property (readonly) QBXMPPJID *jid;
@property (readonly) NSString *nick;
@property (readonly) NSString *role;

@end
