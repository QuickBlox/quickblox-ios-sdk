//
//  SignHelper.h
//  BaseService
//
//  Created by Igor Khomenko on 2/5/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignHelper : NSObject

+ (NSString *)signData:(NSData *)data withSecret:(NSString *)secret;
+ (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret;

@end
