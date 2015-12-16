//
//  QBRTCICEServer.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 06.02.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Entity to describe Stun or TURN ICE server
 */
@interface QBRTCICEServer : NSObject

@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, copy, readonly) NSString *url;

/**
 *  Initializer for RTCICEServer taking url, username, and password.
 */
+ (instancetype)serverWithURL:(NSString *)URL
                     username:(NSString *)username
                     password:(NSString *)password;

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
