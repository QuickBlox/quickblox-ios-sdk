#import <Foundation/Foundation.h>
#import "QBXMPP.h"


@protocol QBXMPPResource <NSObject>
@required

- (QBXMPPJID *)jid;
- (QBXMPPPresence *)presence;

- (NSDate *)presenceDate;

- (NSComparisonResult)compare:(id <QBXMPPResource>)another;

@end
