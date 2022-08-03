//
//  NSString+Videochat.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Videochat)

/**
 *  Removes [ ]+ symbols and trim whitespaces and new line characters
 *
 *  @return clean string
 */
- (NSString *)stringByTrimingWhitespace;
- (BOOL)endsInWhitespaceCharacter;

- (BOOL)validateWithRegexes:(NSArray <NSString *> *)regexes;
- (NSString *)firstLetter;

@end

NS_ASSUME_NONNULL_END
