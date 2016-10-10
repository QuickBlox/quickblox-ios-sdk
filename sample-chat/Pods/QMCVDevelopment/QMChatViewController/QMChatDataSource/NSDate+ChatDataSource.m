//
//  NSDate+ChatDataSource.m
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "NSDate+ChatDataSource.h"

const NSCalendarUnit componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);

@implementation NSDate (ChatDataSource)

- (NSCalendar *)calendar
{
    static NSCalendar *sharedCalendar = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedCalendar = [NSCalendar currentCalendar];
    });
    
    return sharedCalendar;
}

- (NSComparisonResult)compareWithDate:(NSDate *)dateToCompareWith {

    NSUInteger date1 = (NSUInteger)[self timeIntervalSince1970];
    NSUInteger date2 = (NSUInteger)[dateToCompareWith timeIntervalSince1970];
    
    if (date1 > date2) {
        return NSOrderedDescending;
    }
    else if (date2 > date1) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSDate *)dateAtStartOfDay {
    return [[self calendar] startOfDayForDate:self];
}

- (NSDate *)dateAtEndOfDay {
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1;
    dateComponents.second = -1;
    
 
    NSDate *endDate =  [[self calendar] dateByAddingComponents:dateComponents
                                                  toDate:[self dateAtStartOfDay]
                                                 options:0];
    return endDate;
}

- (NSString *)stringDate {
    
    return [self formattedStringFromDate];
}

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    return ([self compare:startDate] == NSOrderedDescending &&
            [self compare:endDate]  == NSOrderedAscending);
}

- (NSString *)stringDateWithFormat:(NSString *)dateFormat {
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.timeZone = [self calendar].timeZone;
        [dateFormatter setDateFormat:@"d MMMM YYYY"];
    });
    
    if (dateFormat.length) {
        [dateFormatter setDateFormat:dateFormat];
    }
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)formattedStringFromDate
{
    NSString *formattedString = nil;
    NSDateComponents *components = [[self calendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    NSDateComponents *currentComponents = [[self calendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (components.day == currentComponents.day && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [self formatDateForDayRange];
    }
    else if (components.day == currentComponents.day - 1 && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [self formatDateForDayRange];
    }
    else if (components.weekOfMonth == currentComponents.weekOfMonth && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [self formatDateForWeekRange];
    }
    else if (components.year == currentComponents.year) {
        
        formattedString = [self formatDateForMonthRange];
    }
    else {
        
        formattedString = [self formatDateForYearRange];
    }
    
    return formattedString;
}

- (NSString *)formatDateForTimeRange:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    });
    
    return [formatter stringFromDate:date];
}

- (NSString *)formatDateForDayRange
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.doesRelativeDateFormatting = YES;
    });
    
    return [formatter stringFromDate:self];
}

- (NSString *)formatDateForWeekRange
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEEE";
    });
    
    return [formatter stringFromDate:self];
}

- (NSString *)formatDateForMonthRange
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"LLLL d";
    });
    
    return [formatter stringFromDate:self];
}

- (NSString *)formatDateForYearRange
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"LLLL d y";
    });
    
    return [formatter stringFromDate:self];
}

@end
