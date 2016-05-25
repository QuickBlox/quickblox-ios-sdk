//
//  NSString+EMOEmoji.h
//  EmojiString
//
//  Created by GabrielMassana on 07/01/2016.
//  Copyright © 2016 GabrielMassana. All rights reserved.
//
//  source https://gist.github.com/dezinezync/6622593
//  source http://stackoverflow.com/a/22956420/1381708
//
#import <Foundation/Foundation.h>

/**
 Category to search emojis on an NSString.
 
 The category allows to check if has emojis, the number of emojis and the range of the emojis.
 */
@interface NSString (EMOEmoji)

 /**
 Calculate the NSRange for every emoji on the string.
 
 @return array with the range for every emoji.
 */
- (NSArray *)emo_emojiRanges;

/**
 Calculate if the string has any emoji.
 
 @return YES if the string has emojis, No otherwise.
 */
- (BOOL)emo_containsEmoji;

/**
 Calculate if the string consists entirely of emoji.
 
 @return YES if the string consists entirely of emoji, No otherwise.
 */
- (BOOL)emo_isPureEmojiString;

/**
 Calculate number of emojis on the string.
 
 @return the total number of emojis.
 */
- (NSInteger)emo_emojiCount;

@end
