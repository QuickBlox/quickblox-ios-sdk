//
//  NSDate+Chat.m
//  sample-chat
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

- (NSString *)setupDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateString = @"";
    
    if ([NSCalendar.currentCalendar isDateInToday:self]) {
        formatter.dateFormat = @"HH:mm";
        dateString = [formatter stringFromDate:self];
    } else if ([NSCalendar.currentCalendar isDateInYesterday:self] == YES) {
        dateString = @"Yesterday";
    } else if ([self isHasSameComponents:NSCalendarUnitYear asDate:[NSDate date]] == YES) {
        formatter.dateFormat = @"d MMM";
        dateString = [formatter stringFromDate:self];
    } else {
        formatter.dateFormat = @"d.MM.yy";
        dateString = [formatter stringFromDate:self];
    }
    
    return dateString;
}

@end
