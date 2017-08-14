//
//  QMDateUtils.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/19/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMDateUtils.h"

@implementation QMDateUtils

static NSArray <NSString *> *_shortWeekdaySymbols = nil;
static NSArray <NSString *> *_shortMonthSymbols = nil;
static BOOL qm_dateHas12hFormat = NO;
static BOOL qm_monthFirst = NO;

static NSString *qm_dateSeparator = @".";

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        
        _shortWeekdaySymbols = dateFormatter.shortWeekdaySymbols;
        _shortMonthSymbols = dateFormatter.shortMonthSymbols;
        
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        NSRange amRange = [dateString rangeOfString:[dateFormatter AMSymbol]];
        NSRange pmRange = [dateString rangeOfString:[dateFormatter PMSymbol]];
        qm_dateHas12hFormat = !(amRange.location == NSNotFound &&
                                pmRange.location == NSNotFound);
        
        dateString =
        [NSDateFormatter dateFormatFromTemplate:@"MdY" options:0
                                         locale:[NSLocale currentLocale]];
        if ([dateString rangeOfString:@"."].location != NSNotFound) {
            qm_dateSeparator = @".";
        }
        else if ([dateString rangeOfString:@"/"].location != NSNotFound) {
            qm_dateSeparator = @"/";
        }
        else if ([dateString rangeOfString:@"-"].location != NSNotFound) {
            qm_dateSeparator = @"-";
        }
        
        NSRange range = [dateString rangeOfString:[NSString stringWithFormat:@"M%@d", qm_dateSeparator]];
        
        if (range.location != NSNotFound) {
            qm_monthFirst = YES;
        }
        
    });
}

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
        
        formattedString = [NSString stringWithFormat:@"%@ %@ %@", [self formatDateForTimeRange:date], timePrefix, [self formatDateForTimeRange:date]];
    }
    else {
        
        formattedString = [NSString stringWithFormat:@"%@", [self formatDateForString:date]];
    }
    
    return formattedString;
}

+ (NSString *)stringForShortTimeWithHours:(int)hours
                                  minutes:(int)minutes {
    
    if (qm_dateHas12hFormat) {
        
        if (hours < 12) {
            return [[NSString alloc] initWithFormat:@"%d:%02d AM",
                    hours == 0 ? 12 : hours, minutes];
        }
        else {
            
            return [[NSString alloc] initWithFormat:@"%d:%02d PM",
                    (hours - 12 == 0) ? 12 : (hours - 12), minutes];
        }
    }
    else {
        
        return [[NSString alloc] initWithFormat:@"%02d:%02d",
                hours, minutes];
    }
}

+ (NSString *)stringForFullDateWithDay:(int)day
                                 month:(int)month
                                  year:(int)year {
    
    if (qm_monthFirst) {
        
        return [NSString stringWithFormat:@"%d%@%d%@%02d",
                month,
                qm_dateSeparator,
                day,
                qm_dateSeparator,
                year - 100];
    }
    else {
        
        return [NSString stringWithFormat:@"%d%@%02d%@%02d",
                day,
                qm_dateSeparator,
                month,
                qm_dateSeparator,
                year - 100];
    }
}

+ (NSString *)formattedShortDateString:(NSDate *)date {
    
    time_t t = date.timeIntervalSince1970;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo_now.tm_year != timeinfo.tm_year) {
        
        return [self stringForFullDateWithDay:timeinfo.tm_mday
                                        month:timeinfo.tm_mon + 1
                                         year:timeinfo.tm_year];
    }
    else {
        
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        
        if (dayDiff == 0) {
            
            return [self stringForShortTimeWithHours:timeinfo.tm_hour
                                             minutes:timeinfo.tm_min];
        }
        else if (dayDiff > -7 && dayDiff <= -1) {
            
            return _shortWeekdaySymbols[timeinfo.tm_wday];
        }
        else {
            
            return [self stringForFullDateWithDay:timeinfo.tm_mday
                                            month:timeinfo.tm_mon + 1
                                             year:timeinfo.tm_year];
        }
    }
    //    else if (timeinfo_now.tm_mon != timeinfo.tm_mon) {
    //        return _shortMonthSymbols[timeinfo.tm_mon];
    //    }
    //    else if (timeinfo_now.tm_yday != timeinfo.tm_yday) {
    //        return _shortWeekdaySymbols[timeinfo.tm_wday];
    //    }
    //    else {
    //
//            if (qm_dateHas12hFormat) {
//    
//                if (timeinfo.tm_hour < 12) {
//                    return [[NSString alloc] initWithFormat:@"%d:%02d AM",
//                            timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
//                }
//                else {
//                    return [[NSString alloc] initWithFormat:@"%d:%02d PM",
//                            (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
//                }
//            }
//            else {
//                return [[NSString alloc] initWithFormat:@"%02d:%02d",
//                        timeinfo.tm_hour, timeinfo.tm_min];
//            }
    //    }
}

+ (NSString *)formatDateForTimeRange:(NSDate *)date {
    
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForDayRange:(NSDate *)date {
    
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.doesRelativeDateFormatting = YES;
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForMonthRange:(NSDate *)date {
    
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"LLLL d";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForYearRange:(NSDate *)date {
    
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
