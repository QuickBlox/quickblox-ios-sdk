//
//  NSString+Chat.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "NSString+Chat.h"

@implementation NSString (Chat)

- (NSString *)stringByTrimingWhitespace {
    
    NSString *squashed =
    [self stringByReplacingOccurrencesOfString:@"[ ]+"
                                    withString:@" "
                                       options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
    
    return [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)endsInWhitespaceCharacter {
    NSUInteger stringLength = [self length];
    if (stringLength == 0) {
        return NO;
    }
    unichar lastChar = [self characterAtIndex:stringLength-1];
    return [[NSCharacterSet whitespaceCharacterSet] characterIsMember:lastChar];
}

@end
