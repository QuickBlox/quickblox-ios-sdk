//
//  NSDate+Chat.h
//  sample-conference-videochat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Chat)
- (BOOL)isHasSameComponents:(NSCalendarUnit)unitFlags asDate:(NSDate *)date;
- (NSString *)setupDate;
@end

NS_ASSUME_NONNULL_END
