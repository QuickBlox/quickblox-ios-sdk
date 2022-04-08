//
//  NSString+Chat.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Chat)

/**
 *  Removes [ ]+ symbols and trim whitespaces and new line characters
 *
 *  @return clean string
 */
- (NSString *)stringByTrimingWhitespace;
- (BOOL)validateWithRegexes:(NSArray <NSString *> *)regexes;
- (NSString *)firstLetter;
- (CGFloat)stringWidth;

@end

NS_ASSUME_NONNULL_END
