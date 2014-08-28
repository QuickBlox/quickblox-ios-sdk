#import <Foundation/Foundation.h>
#import "QBXMPPUser.h"
#import "QBXMPP.h"

#if !TARGET_OS_IPHONE
  #import <Cocoa/Cocoa.h>
#endif

@class QBXMPPResourceMemoryStorage;


@interface QBXMPPUserMemoryStorage : NSObject <QBXMPPUser, NSCopying, NSCoding>
{
	QBXMPPJID *jid;
	
	NSMutableDictionary *resources;
	QBXMPPResourceMemoryStorage *primaryResource;
	
#if TARGET_OS_IPHONE
	UIImage *photo;
#else
	NSImage *photo;
#endif
}

@property (nonatomic, assign) NSMutableDictionary *itemAttributes;

/*	From the XMPPUser protocol
	
- (XMPPJID *)jid;
- (NSString *)nickname;

- (BOOL)isOnline;
- (BOOL)isPendingApproval;

- (id <XMPPResource>)primaryResource;
- (id <XMPPResource>)resourceForJID:(XMPPJID *)jid;

- (NSArray *)allResources;

*/

/**
 * Simple convenience method.
 * If a nickname exists for the user, the nickname is returned.
 * Otherwise the jid is returned (as a string).
**/
- (NSString *)displayName;

/**
 * If XMPPvCardAvatarModule is included in the framework, the XMPPRoster will automatically integrate with it,
 * and we'll save the the user photos after they've been downloaded.
**/
#if TARGET_OS_IPHONE
@property (nonatomic, retain, readonly) UIImage *photo;
#else
@property (nonatomic, retain, readonly) NSImage *photo;
#endif

/**
 * 
**/

- (NSComparisonResult)compareByName:(QBXMPPUserMemoryStorage *)another;
- (NSComparisonResult)compareByName:(QBXMPPUserMemoryStorage *)another options:(NSStringCompareOptions)mask;

- (NSComparisonResult)compareByAvailabilityName:(QBXMPPUserMemoryStorage *)another;
- (NSComparisonResult)compareByAvailabilityName:(QBXMPPUserMemoryStorage *)another options:(NSStringCompareOptions)mask;

@end
