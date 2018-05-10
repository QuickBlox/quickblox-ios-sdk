//
//  NSString+QM.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QM)

/**
 *  Removes [ ]+ symbols and trim whitespaces and new line characters
 *
 *  @return clean string
 */
- (NSString *)stringByTrimingWhitespace;

@end
