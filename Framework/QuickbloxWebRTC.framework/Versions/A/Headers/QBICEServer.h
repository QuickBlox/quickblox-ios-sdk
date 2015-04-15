//
//  QBICEServer.h
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 06.02.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBICEServer : NSObject

/**
 *  Initializer for RTCICEServer taking url, username, and password.
 */
+ (instancetype)serverWithURL:(NSURL *)URL
                     username:(NSString *)username
                     password:(NSString *)password;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
