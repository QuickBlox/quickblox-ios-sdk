//
//  KeychainHelper.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 12/2/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainHelper : NSObject

+ (OSStatus)saveKey:(NSString *)key data:(id)data;
+ (id)loadKey:(NSString *)key;
+ (OSStatus)deleteKey:(NSString *)key;

@end
