#import "QBXMPPModule.h"
@class QBXMPPMessage;
@class QBXMPPIDTracker;

#define _XMPP_MESSAGE_CARBONS_H

@interface QBXMPPMessageCarbons : QBXMPPModule
{
    BOOL autoEnableMessageCarbons;
    BOOL allowsUntrustedMessageCarbons;
    BOOL messageCarbonsEnabled;
    
    QBXMPPIDTracker *xmppIDTracker;
}

/**
 * Wether or not to automatically enable Message Carbons.
 *
 * Default YES
 **/
@property (assign) BOOL autoEnableMessageCarbons;

/**
 * Wether Message Carbons is currently enabled or not.
 *
 * @see enableMessageCarbons
 * @see disableMessageCarbons
 **/
@property (assign, getter = isMessageCarbonsEnabled,readonly) BOOL messageCarbonsEnabled;

/**
 * Whether Message Carbons are validated before calling the delegate methods.
 *
 * @see xmppMessageCarbons:willReceiveMessage:outgoing:
 * @see xmppMessageCarbons:didReceiveMessage:outgoing:
 *
 * A Message Carbon is Trusted if:
 *
 * - It is from the Stream's Bare JID
 * - Sent Forward Messages are from the Stream's JID
 * - Received Forward Messages are to the Stream's JID
 *
 * Default is NO
 **/
@property (assign) BOOL allowsUntrustedMessageCarbons;

/**
 * Enable Message Carbons
 **/
- (void)enableMessageCarbons;

/**
 * Disable Message Carbons
 **/
- (void)disableMessageCarbons;

@end

@protocol QBXMPPMessageCarbonsDelegate <NSObject>

- (void)xmppMessageCarbons:(QBXMPPMessageCarbons *)xmppMessageCarbons willReceiveMessage:(QBXMPPMessage *)message outgoing:(BOOL)isOutgoing;

- (void)xmppMessageCarbons:(QBXMPPMessageCarbons *)xmppMessageCarbons didReceiveMessage:(QBXMPPMessage *)message outgoing:(BOOL)isOutgoing;

@end