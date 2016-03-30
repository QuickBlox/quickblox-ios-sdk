//
//  QMDateUtils.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/19/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMDateUtils.h"

@implementation QMDateUtils

+ (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSString *formattedString = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSString *sectionDate = [self formatDateForTimeRange:date];
    
    if (components.day == currentComponents.day && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@", [self formatDateForDayRange:date], sectionDate];
    }
    else if (components.day == currentComponents.day - 1 && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@", [self formatDateForDayRange:date], sectionDate];
    }
    else if (components.weekOfMonth == currentComponents.weekOfMonth && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@", [self formatDateForWeekRange:date], sectionDate];
    }
    else if (components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@", [self formatDateForMonthRange:date], sectionDate];
    }
    else {
        
        formattedString = [NSString stringWithFormat:@"%@ %@", [self formatDateForYearRange:date], sectionDate];
    }
    
    return formattedString;
}

+ (NSString *)formattedLastSeenString:(NSDate *)date withTimePrefix:(NSString *)timePrefix
{
    NSString *formattedString = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (components.day == currentComponents.day && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@ %@", [self formatDateForDayRange:date], timePrefix, [self formatDateForTimeRange:date]];
    }
    else if (components.day == currentComponents.day - 1 && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@ %@", [self formatDateForDayRange:date], timePrefix, [self formatDateForTimeRange:date]];
    }
    else if (components.weekOfMonth == currentComponents.weekOfMonth && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %@ %@", [self formatDateForWeekRange:date], timePrefix, [self formatDateForTimeRange:date]];
    }
    else {
        
        formattedString = [NSString stringWithFormat:@"%@", [self formatDateForString:date]];
    }
    
    return formattedString;
}

+ (NSString *)formattedShortDateString:(NSDate *)date
{
    NSString *formattedString = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (components.day == currentComponents.day && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@", [self formatDateForTimeRange:date]];
    }
    else if (components.day == currentComponents.day - 1 && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@", [self formatDateForDayRange:date]];
    }
    else if (components.weekOfMonth == currentComponents.weekOfMonth && components.month == currentComponents.month && components.year == currentComponents.year) {
        
        formattedString = [NSString stringWithFormat:@"%@", [self formatDateForWeekRange:date]];
    }
    else {
        
        formattedString = [NSString stringWithFormat:@"%@", [self formatShortDateForString:date]];
    }
    
    return formattedString;
}

+ (NSString *)formatDateForTimeRange:(NSDate *)date
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

+ (NSString *)formatDateForDayRange:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.doesRelativeDateFormatting = YES;
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForWeekRange:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEEE";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForMonthRange:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"LLLL d";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForYearRange:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"LLLL d y";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForString:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d/MM/y";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatShortDateForString:(NSDate *)date
{
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d.MM.yy";
    });
    
    return [formatter stringFromDate:date];
}

@end
