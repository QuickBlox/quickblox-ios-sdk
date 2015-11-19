//
//  QMDateUtils.m
//  Pods
//
//  Created by Vitaliy Gorbachov on 11/19/15.
//
//

#import "QMDateUtils.h"

@implementation QMDateUtils

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter* formatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm";
    });
    
    return formatter;
}

+ (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSString *formattedString = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSString *sectionDate = [[self dateFormatter] stringFromDate:date];
    
    if (components.day == currentComponents.day && components.month == currentComponents.month && components.year == currentComponents.year) {
        formattedString = [NSString stringWithFormat:@"Today %@", sectionDate];
    } else if (components.day == currentComponents.day-1 && components.month == currentComponents.month && components.year == currentComponents.year) {
        formattedString = [NSString stringWithFormat:@"Yesterday %@", sectionDate];
    } else if (components.year == components.year) {
        formattedString = [NSString stringWithFormat:@"%@ %ld %@", [self monthFromNumber:components.month], (long)components.day, sectionDate];
    } else {
        formattedString = [NSString stringWithFormat:@"%@ %ld %ld %@", [self monthFromNumber:components.month], (long)components.day, (long)components.year, sectionDate];
    }
    return formattedString;
}

+ (NSString *)monthFromNumber:(NSInteger)number
{
    NSDictionary *dict = @{@1: @"January",
                           @2: @"February",
                           @3: @"March",
                           @4: @"April",
                           @5: @"May",
                           @6: @"June",
                           @7: @"July",
                           @8: @"August",
                           @9: @"September",
                           @10: @"October",
                           @11: @"November",
                           @12: @"December"};
    return dict[@(number)];
}

@end
