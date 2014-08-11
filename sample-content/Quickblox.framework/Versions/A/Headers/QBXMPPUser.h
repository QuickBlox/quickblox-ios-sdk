#import <Foundation/Foundation.h>
#import "QBXMPP.h"

@protocol QBXMPPResource;


@protocol QBXMPPUser <NSObject>
@required

- (QBXMPPJID *)jid;
- (NSString *)nickname;

- (BOOL)isOnline;
- (BOOL)isPendingApproval;

- (id <QBXMPPResource>)primaryResource;
- (id <QBXMPPResource>)resourceForJID:(QBXMPPJID *)jid;

- (NSArray *)allResources;

@end
