//
//  NSString+Chat.m
//  sample-push-notifications
//
//  Created by Injoit on 18.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
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

- (BOOL)validateWithRegexes:(NSArray <NSString *> *)regexes {
    for (NSString *regex in regexes) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:self]) {
            return true;
        }
    }
    return false;
}

@end
