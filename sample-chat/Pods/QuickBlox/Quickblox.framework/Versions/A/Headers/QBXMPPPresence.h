#import <Foundation/Foundation.h>
#import "QBXMPPElement.h"

/**
 * The XMPPPresence class represents a <presence> element.
 * It extends XMPPElement, which in turn extends NSXMLElement.
 * All <presence> elements that go in and out of the
 * xmpp stream will automatically be converted to XMPPPresence objects.
 * 
 * This class exists to provide developers an easy way to add functionality to presence processing.
 * Simply add your own category to XMPPPresence to extend it with your own custom methods.
**/

@interface QBXMPPPresence : QBXMPPElement

// Converts an NSXMLElement to an XMPPPresence element in place (no memory allocations or copying)
+ (QBXMPPPresence *)presenceFromElement:(NSXMLElement *)element;

+ (QBXMPPPresence *)presence;
+ (QBXMPPPresence *)presenceWithType:(NSString *)type;
+ (QBXMPPPresence *)presenceWithType:(NSString *)type to:(QBXMPPJID *)to;
+ (QBXMPPPresence *)presenceWithStatus:(NSString *)status;

- (id)init;
- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)type to:(QBXMPPJID *)to;
- (id)initWithStatus:(NSString *)status;

- (NSString *)type;

- (NSString *)show;
- (NSString *)status;

- (int)priority;

- (int)intShow;

- (BOOL)isErrorPresence;

@end
