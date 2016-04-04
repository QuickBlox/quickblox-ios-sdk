//
//  NSString+STKMD5.m
//  StickerPipe
//
//  Created by Vadim Degterev on 20.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "NSString+STKMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (STKMD5)

- (NSString *)stk_md5String {
    
    const char * pointer = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return  string;
}

@end
