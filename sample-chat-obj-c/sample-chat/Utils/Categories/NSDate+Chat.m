//
//  NSDate+Chat.m
//  samplechat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "NSDate+Chat.h"

@implementation NSDate (Chat)

- (BOOL)isHasSameComponents:(NSCalendarUnit)unitFlags asDate:(NSDate *)date {
    NSCalendar *calendar = NSCalendar.autoupdatingCurrentCalendar;
    NSDateComponents *otherDay = [calendar components:unitFlags fromDate:date];
    NSDateComponents *today = [calendar components:unitFlags fromDate:self];
    return [otherDay isEqual:today];
}

@end
