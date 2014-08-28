#import <Foundation/Foundation.h>
#import "QBXMPPResource.h"

@class QBXMPPJID;
@class QBXMPPIQ;
@class QBXMPPPresence;


@interface QBXMPPResourceMemoryStorage : NSObject <QBXMPPResource, NSCopying, NSCoding>
{
	QBXMPPJID *jid;
	QBXMPPPresence *presence;
	
	NSDate *presenceDate;
}

// See the XMPPResource protocol for available methods.

@end
