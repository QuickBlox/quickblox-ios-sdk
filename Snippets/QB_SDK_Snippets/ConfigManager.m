//
//  ConfigManager.m
//  QB_SDK_Snippets
//
//  Created by Igor Khomenko on 1/28/15.
//  Copyright (c) 2015 Injoit. All rights reserved.
//

#import "ConfigManager.h"

@implementation ConfigManager{
    NSMutableDictionary *servers;
    NSString *activeServer;
    BOOL userUser1;
}

+ (instancetype)sharedManager{
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)parseJson{
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"servers" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *root = [NSJSONSerialization
                 JSONObjectWithData:jsonData
                 options:0
                 error:&error];
    
    servers = root[@"servers"];
    
    activeServer = root[@"active"];
    
    userUser1 = [root[@"use_first_user"] boolValue];
    
    if(error) {
        NSLog(@"error: %@", error);
    }else{
        NSLog(@"json parsed");
    }
}

- (instancetype)init{
    self = [super init];
    if(self){
        [self parseJson];
    }
    return self;
}

- (NSUInteger)appId{
    return [servers[activeServer][@"app_id"] integerValue];
}

- (NSString *)authKey{
    return servers[activeServer][@"auth_key"];
}

- (NSString *)authSecret{
    return servers[activeServer][@"auth_secret"];
}

- (NSString *)accountKey{
    return @"7yvNe17TnjNUqDoPwfqp";
}

- (NSString *)apiDomain{
    return servers[activeServer][@"api_domain"];
}

- (NSString *)chatDomain{
    return servers[activeServer][@"chat_domain"];
}

- (NSString *)bucketName{
    return servers[activeServer][@"bucket_name"];
}

- (NSUInteger)testUserId1{
    if(userUser1){
        return [servers[activeServer][@"test_user_id1"] integerValue];
    }else{
        return [servers[activeServer][@"test_user_id2"] integerValue];
    }
}

- (NSUInteger)testUserId2{
    if(userUser1){
        return [servers[activeServer][@"test_user_id2"] integerValue];
    }else{
        return [servers[activeServer][@"test_user_id1"] integerValue];
    }
}

- (NSString *)testUserLogin1{
    if(userUser1){
        return servers[activeServer][@"test_user_login1"];
    }else{
        return servers[activeServer][@"test_user_login2"];
    }
}

- (NSString *)testUserLogin2{
    if(userUser1){
        return servers[activeServer][@"test_user_login2"];
    }else{
        return servers[activeServer][@"test_user_login1"];
    }
}

- (NSString *)testUserPassword1{
    if(userUser1){
        return servers[activeServer][@"test_user_password1"];
    }else{
        return servers[activeServer][@"test_user_password2"];
    }
}

- (NSString *)testUserPassword2{
    if(userUser1){
        return servers[activeServer][@"test_user_password2"];
    }else{
        return servers[activeServer][@"test_user_password1"];
    }
}

- (NSString *)testUserEmail1{
    return @"";
}

- (NSString *)testUserEmail2{
    return @"";
}

- (NSString *)dialogId{
    return servers[activeServer][@"dialog_id"];
}

- (NSString *)dialogJid{
    return [NSString stringWithFormat:@"%d_%@@muc.%@", [self appId], [self dialogId], [self chatDomain]];
}

@end
