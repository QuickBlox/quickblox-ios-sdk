#import <Foundation/Foundation.h>
#import "QBXMPPElement.h"

@class QBXMPPIQ;
@class QBXMPPMessage;
@class QBXMPPPresence;


@interface QBXMPPElement(XEP0297)

#pragma mark Forwarded Stanza

- (QBXMPPElement *)forwardedStanza;

- (BOOL)hasForwardedStanza;

- (BOOL)isForwardedStanza;

#pragma mark Delayed Delivery Date

- (NSDate *)forwardedStanzaDelayedDeliveryDate;

#pragma mark XMPPElement

- (QBXMPPIQ *)forwardedIQ;

- (BOOL)hasForwardedIQ;

- (QBXMPPMessage *)forwardedMessage;

- (BOOL)hasForwardedMessage;

- (QBXMPPPresence *)forwardedPresence;

- (BOOL)hasForwardedPresence;

@end