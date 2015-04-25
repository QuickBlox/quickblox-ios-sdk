//
//  GCDAsyncProxySocket.h
//  OnionKit
//
//  Created by Christopher Ballinger on 11/19/13.
//  Copyright (c) 2013 ChatSecure. All rights reserved.
//

#import "QBGCDAsyncSocket.h"

typedef NS_ENUM(int16_t, QBGCDAsyncSocketSOCKSVersion) {
    QBGCDAsyncSocketSOCKSVersion4 = 0,    // Not implemented
    QBGCDAsyncSocketSOCKSVersion4a,       // Not implemented
    QBGCDAsyncSocketSOCKSVersion5         // WIP
};

typedef NS_ENUM(int16_t, QBGCDAsyncProxySocketError) {
	QBGCDAsyncProxySocketNoError = 0,           // Never used
    QBGCDAsyncProxySocketAuthenticationError
};

@interface QBGCDAsyncProxySocket : QBGCDAsyncSocket <QBGCDAsyncSocketDelegate>

// SOCKS proxy settings
@property (nonatomic, strong, readonly) NSString *proxyHost;
@property (nonatomic, readonly) uint16_t proxyPort;
@property (nonatomic, readonly) QBGCDAsyncSocketSOCKSVersion proxyVersion;

@property (nonatomic, strong, readonly) NSString *proxyUsername;
@property (nonatomic, strong, readonly) NSString *proxyPassword;

/**
 * SOCKS Proxy settings
 **/
- (void) setProxyHost:(NSString*)host port:(uint16_t)port version:(QBGCDAsyncSocketSOCKSVersion)version;
- (void) setProxyUsername:(NSString *)username password:(NSString*)password;

@end
