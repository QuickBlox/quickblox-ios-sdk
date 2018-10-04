//
//  QBRTCICEServer.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Entity to describe Stun or TURN ICE server
 */
@interface QBRTCICEServer : NSObject

@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, copy, readonly) NSArray <NSString *> *urls;

/**
 *  Initializer for RTCICEServer taking urls, username, and password.
 */
+ (instancetype)serverWithURLs:(NSArray <NSString *> *)URLs
                      username:(NSString *)username
                      password:(NSString *)password;

- (instancetype)init NS_UNAVAILABLE;

@end
