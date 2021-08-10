//
//  NSString+Chat.m
//  sample-conference-videochat
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

- (BOOL)validateWithRegexes:(NSArray <NSString *> *)regexes {
    for (NSString *regex in regexes) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:self]) {
            return true;
        }
    }
    return false;
}

- (NSString *)firstLetter {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *name = [self stringByTrimmingCharactersInSet:characterSet];
    NSMutableString * firstLetter = [NSMutableString string];
    NSString * firstChar = [name substringWithRange:[name rangeOfComposedCharacterSequenceAtIndex:0]];
    [firstLetter appendString:[firstChar uppercaseString]];
    return firstLetter.copy;
}

@end
