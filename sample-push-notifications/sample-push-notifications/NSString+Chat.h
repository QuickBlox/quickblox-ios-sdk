//
//  NSString+Chat.h
//  sample-push-notifications
//
//  Created by Injoit on 18.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Chat)

/**
 *  Removes [ ]+ symbols and trim whitespaces and new line characters
 *
 *  @return clean string
 */
- (NSString *)stringByTrimingWhitespace;
- (BOOL)endsInWhitespaceCharacter;

- (BOOL)validateWithRegexes:(NSArray <NSString *> *)regexes;

@end

NS_ASSUME_NONNULL_END
