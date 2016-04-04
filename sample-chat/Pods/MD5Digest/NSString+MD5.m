//
//  NSString+MD5.m
//
//  Created by Keith Smiley on 3/25/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+MD5.h"

@implementation NSString (MD5)

- (NSString *)MD5Digest
{
    const char* input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

@end
