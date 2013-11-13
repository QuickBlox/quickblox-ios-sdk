//
//  CharactersEscapeService.h
//  sample-chat
//
//  Created by Igor Khomenko on 11/13/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CharactersEscapeService : NSObject

+ (NSString *)escape:(NSString *)unescapedString;
+ (NSString *)unescape:(NSString *)escapedString;

@end
