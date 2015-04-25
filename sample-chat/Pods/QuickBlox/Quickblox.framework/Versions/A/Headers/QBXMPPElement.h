#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
  #import "QBDDXML.h"
#endif

@class QBXMPPJID;

/**
 * The XMPPElement provides the base class for XMPPIQ, XMPPMessage & XMPPPresence.
 * 
 * This class extends NSXMLElement.
 * The NSXML classes (NSXMLElement & NSXMLNode) provide a full-featured library for working with XML elements.
 * 
 * On the iPhone, the KissXML library provides a drop-in replacement for Apple's NSXML classes.
**/

@interface QBXMPPElement : NSXMLElement <NSCoding>

- (NSString *)elementID;

- (QBXMPPJID *)to;
- (QBXMPPJID *)from;

- (NSString *)toStr;
- (NSString *)fromStr;

@end
