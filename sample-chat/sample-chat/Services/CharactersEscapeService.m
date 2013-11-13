//
//  CharactersEscapeService.m
//  sample-chat
//
//  Created by Igor Khomenko on 11/13/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "CharactersEscapeService.h"

@implementation CharactersEscapeService

+ (NSString *)escape:(NSString *)unescapedString{
    NSMutableString *mutabeCopy = [unescapedString mutableCopy];
    [mutabeCopy replaceOccurrencesOfString:@"\\" withString:@"\\5c" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@" " withString:@"\\20" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\"" withString:@"\\22" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"&" withString:@"\\26" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"'" withString:@"\\27" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"/" withString:@"\\2f" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@":" withString:@"\\3a" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"<" withString:@"\\3c" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@">" withString:@"\\3e" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"@" withString:@"\\40" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    
	return mutabeCopy;
}

+ (NSString *)unescape:(NSString *)escapedString{
	 NSMutableString *mutabeCopy = [escapedString mutableCopy];
    [mutabeCopy replaceOccurrencesOfString:@"\\5c" withString:@"\\" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\20" withString:@" " options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\22" withString:@"\"" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\26" withString:@"&" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\27" withString:@"'" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\2f" withString:@"/" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\3a" withString:@":" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\3c" withString:@"<" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\3e" withString:@">" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    [mutabeCopy replaceOccurrencesOfString:@"\\40" withString:@"@" options:0 range:NSMakeRange(0, mutabeCopy.length)];
    
    return mutabeCopy;
}

@end

//return node.replace(/^\s+|\s+$/g, '')
//  .replace(/\\/g,  "\\5c")   \
//  .replace(/ /g,   "\\20")
//  .replace(/\"/g,  "\\22")   "
//  .replace(/\&/g,  "\\26")   &
//  .replace(/\'/g,  "\\27")   '
//  .replace(/\//g,  "\\2f")   /
//  .replace(/:/g,   "\\3a")   :
//  .replace(/</g,   "\\3c")   <
//  .replace(/>/g,   "\\3e")   >
//  .replace(/@/g,   "\\40");  @
//
// http://www.cisco.com/en/US/docs/ios/fundamentals/command/reference/cf_ap1.html
