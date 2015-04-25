#import <Foundation/Foundation.h>
#import "QBXMPPElement.h"

/**
 * The XMPPIQ class represents an <iq> element.
 * It extends XMPPElement, which in turn extends NSXMLElement.
 * All <iq> elements that go in and out of the
 * xmpp stream will automatically be converted to XMPPIQ objects.
 * 
 * This class exists to provide developers an easy way to add functionality to IQ processing.
 * Simply add your own category to XMPPIQ to extend it with your own custom methods.
**/

@interface QBXMPPIQ : QBXMPPElement

/**
 * Converts an NSXMLElement to an XMPPIQ element in place (no memory allocations or copying)
**/
+ (QBXMPPIQ *)iqFromElement:(NSXMLElement *)element;

/**
 * Creates and returns a new autoreleased XMPPIQ element.
 * If the type or elementID parameters are nil, those attributes will not be added.
**/
+ (QBXMPPIQ *)iq;
+ (QBXMPPIQ *)iqWithType:(NSString *)type;
+ (QBXMPPIQ *)iqWithType:(NSString *)type to:(QBXMPPJID *)jid;
+ (QBXMPPIQ *)iqWithType:(NSString *)type to:(QBXMPPJID *)jid elementID:(NSString *)eid;
+ (QBXMPPIQ *)iqWithType:(NSString *)type toStr:(NSString *)to elementID:(NSString *)eid;
+ (QBXMPPIQ *)iqWithType:(NSString *)type to:(QBXMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement;

+ (QBXMPPIQ *)iqWithType:(NSString *)type elementID:(NSString *)eid;
+ (QBXMPPIQ *)iqWithType:(NSString *)type elementID:(NSString *)eid child:(NSXMLElement *)childElement;
+ (QBXMPPIQ *)iqWithType:(NSString *)type child:(NSXMLElement *)childElement;
/**
 * Creates and returns a new XMPPIQ element.
 * If the type or elementID parameters are nil, those attributes will not be added.
**/
- (id)init;
- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)type to:(QBXMPPJID *)jid;
- (id)initWithType:(NSString *)type toStr:(NSString *)to elementID:(NSString *)eid;
- (id)initWithType:(NSString *)type to:(QBXMPPJID *)jid elementID:(NSString *)eid;
- (id)initWithType:(NSString *)type to:(QBXMPPJID *)jid elementID:(NSString *)eid child:(NSXMLElement *)childElement;

/**
 * Returns the type attribute of the IQ.
 * According to the XMPP protocol, the type should be one of 'get', 'set', 'result' or 'error'.
 * 
 * This method converts the attribute to lowercase so
 * case-sensitive string comparisons are safe (regardless of server treatment).
**/
- (NSString *)type;

/**
 * Convenience methods for determining the IQ type.
**/
- (BOOL)isGetIQ;
- (BOOL)isSetIQ;
- (BOOL)isResultIQ;
- (BOOL)isErrorIQ;

/**
 * Convenience method for determining if the IQ is of type 'get' or 'set'.
**/
- (BOOL)requiresResponse;

/**
 * The XMPP RFC has various rules for the number of child elements an IQ is allowed to have:
 * 
 * - An IQ stanza of type "get" or "set" MUST contain one and only one child element.
 * - An IQ stanza of type "result" MUST include zero or one child elements.
 * - An IQ stanza of type "error" SHOULD include the child element contained in the
 *   associated "get" or "set" and MUST include an <error/> child.
 * 
 * The childElement returns the single non-error element, if one exists, or nil.
 * The childErrorElement returns the error element, if one exists, or nil.
**/
- (NSXMLElement *)childElement;
- (NSXMLElement *)childErrorElement;

@end
