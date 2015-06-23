//
//  TURNClient.h
//  TURN
//
//  Created by Igor Khomenko on 9/19/12.
//  Copyright (c) 2012 Quickblox. All rights reserved. Check our BAAS quickblox.com
//
//
// This a simple and ad-hoc TURN client (UDP), partially compliant with RFC 5766
//
// Documentation http://www.jdrosen.net/papers/draft-rosenberg-midcom-turn-02.html & http://tools.ietf.org/html/rfc5766
//
// From quickblox.com team with love!
//


#import <Foundation/Foundation.h>
#import "QBGCDAsyncSocket.h"
#import "QBGCDAsyncUdpSocket.h"

// TURN default port
#define TURNPort 3478

// TURN server. See http://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT for setup your own or use free. 

#define allocatedIPKey @"allocatedIPKey"
#define allocatedPortKey @"allocatedPortKey"
#define publicXORAddressKey @"publicXORAddressKey"
//
#define publicNatIPKey @"publicNatIPKey"
#define publicNatPortKey @"publicNatPortKey"
//
#define connectionIDKey @"connectionID"
#define xorPeerAddressKey @"xorPeerAddres"

// Enable/disable auth (some TURN servers use auth, in some we can disable it)
//#define authEnable YES

// Enable/disable log
#define log 1
#define TURNLog(...) if (log) NSLog(__VA_ARGS__)

@protocol QBTURNClientDelegate;
@interface QBTURNClient : NSObject <QBGCDAsyncUdpSocketDelegate, QBGCDAsyncSocketDelegate>{
    NSData *magicCookie;
    
    NSData *NONCE;
    NSData *REALM;
    NSData *USERNAME;
    NSData *MESSAGE_INTEGRITY;
}
@property (nonatomic, retain) QBGCDAsyncUdpSocket *udpSocketVideo;

@property (nonatomic, retain) QBGCDAsyncSocket *tcpSocketControl;
@property (nonatomic, retain) QBGCDAsyncSocket *tcpSocketData;

@property (nonatomic, retain) id<QBTURNClientDelegate>delegate;

// TURN
//
// over UDP
- (void)sendAllocationRequest;
- (void)sendPermissionRequestWithPeer:(NSData *)peer;
- (void)sendRefreshRequestWithLifetime:(int)lifetime;
//
// over TCP
- (void)sendAllocationRequestTCP;
- (void)sendPermissionTCPRequestWithPeer:(NSData *)peer;
- (void)sendConnectionBindRequestTCPWithConnectionID:(NSData *)connectionID;
- (void)sendRefreshRequestTCPWithLifetime:(int)lifetime;

// STUN
//
// over UDP
- (void)sendBindingRequest;
- (void)sendIndicationMessage;
//
// over TCP
- (void)sendBindingRequestTCP;
- (void)sendIndicationMessageTCP;

// other
- (void)setTcpSocketControl:(QBGCDAsyncSocket *)_tcpSocketControl andConnect:(BOOL)connect;

@end


// Turn response type
enum QBTURNResponseType{
	TURNResponseTypeBinding,
	TURNResponseTypeAllocation,
	TURNResponseTypeData,
    TURNResponseTypePermisison,
    TURNResponseTypeConnectionAttempt,
    TURNResponseTypeConnectionBind,
    TURNResponseTypeConnectionBindFail,
    TURNResponseTypeRefresh,
    TURNResponseTypeIndication,
    TURNResponseTypeUndefined
};


// TURN delegate
@protocol QBTURNClientDelegate <NSObject>
@optional
- (void)didReceiveAllocationResponse:(NSDictionary *) data;
- (void)didReceiveBindingResponse:(NSDictionary *) data;
- (void)didReceivePermissionResponse;
- (void)didReceiveData:(NSData *) data;
- (void)didReceiveConnectionAttempt:(NSDictionary *) data;
- (void)didReceiveConnectionBind;
- (void)didFailWithError:(NSString *) error code:(NSInteger)errorCode;
- (void)didConnectToTURNServerUsingTCP:(QBGCDAsyncSocket *)socket;
- (void)chatTURNServerDidDisconnect;
@end