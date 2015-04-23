//
//  ConfigManager.h
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 1/28/15.
//  Copyright (c) 2015 Injoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

+ (instancetype)sharedManager;

- (NSUInteger)appId;
- (NSString *)authKey;
- (NSString *)authSecret;
- (NSString *)accountKey;
- (NSString *)apiDomain;
- (NSString *)chatDomain;
- (NSString *)bucketName;
- (NSUInteger)testUserId1;
- (NSUInteger)testUserId2;
- (NSString *)testUserLogin1;
- (NSString *)testUserLogin2;
- (NSString *)testUserPassword1;
- (NSString *)testUserPassword2;
- (NSString *)testUserEmail1;
- (NSString *)testUserEmail2;
- (NSString *)dialogId;
- (NSString *)dialogJid;

@end
