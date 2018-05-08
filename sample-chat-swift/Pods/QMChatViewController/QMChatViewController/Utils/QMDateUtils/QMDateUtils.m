//
//  QMDateUtils.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/19/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMDateUtils.h"

static BOOL value_dateHas12hFormat = NO;
static BOOL value_monthFirst = NO;
static BOOL isArabic = NO;
static BOOL isKorean = NO;
static NSString *value_date_separator = @".";

@implementation QMDateUtils

+ (void)initialize {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    dateFormatter.timeZone = timeZone;
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[dateFormatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[dateFormatter PMSymbol]];
    value_dateHas12hFormat = !(amRange.location == NSNotFound && pmRange.location == NSNotFound);
    
    dateString = [NSDateFormatter dateFormatFromTemplate:@"MdY" options:0 locale:[NSLocale currentLocale]];
    if ([dateString rangeOfString:@"."].location != NSNotFound) {
        value_date_separator = @".";
    }
    else if ([dateString rangeOfString:@"/"].location != NSNotFound) {
        value_date_separator = @"/";
    }
    else if ([dateString rangeOfString:@"-"].location != NSNotFound) {
        value_date_separator = @"-";
    }
    
    if ([dateString rangeOfString:[NSString stringWithFormat:@"M%@d", value_date_separator]].location != NSNotFound) {
        value_monthFirst = YES;
    }
    
    NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
    if ([identifier isEqualToString:@"ar"] || [identifier hasPrefix:@"ar_"]) {
        isArabic = YES;
        value_date_separator = @"\u060d";
    }
    else if ([identifier isEqualToString:@"ko"] || [identifier hasPrefix:@"ko-"]) {
        isKorean = YES;
    }
}

+ (NSString *)formattedStringFromDate:(NSDate *)date {
    
    time_t t = [date timeIntervalSince1970];
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year) {
        if (value_monthFirst) {
            return [[NSString alloc] initWithFormat:@"%@ %d %04d", [self formatDateForMonthRange:date], timeinfo.tm_mday, timeinfo.tm_year - 100 + 2000];
        }
        else {
            return [[NSString alloc] initWithFormat:@"%d %@ %04d", timeinfo.tm_mday, [self formatDateForMonthRange:date], timeinfo.tm_year - 100 + 2000];
        }
    }
    else {
        
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        BOOL currentWeek = timeinfo.tm_yday >= (timeinfo_now.tm_yday - timeinfo_now.tm_wday);
        
        if (dayDiff == 0
            || dayDiff == -1) {
            
            return [self formatDateForDayRange:date];
        }
        else if (currentWeek) {
            
            return [self formatDateForWeekRange:date];
        }
        else {
            if (value_monthFirst) {
                return [[NSString alloc] initWithFormat:@"%@ %d", [self formatDateForMonthRange:date], timeinfo.tm_mday];
            }
            else {
                return [[NSString alloc] initWithFormat:@"%d %@", timeinfo.tm_mday, [self formatDateForMonthRange:date]];
            }
        }
    }
}

+ (NSString *)formattedLastSeenString:(NSDate *)date withTimePrefix:(NSString *)timePrefix {
    
    time_t t = [date timeIntervalSince1970];
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year) {
        return [self formatDateForString:date];
    }
    else {
        
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        BOOL currentWeek = timeinfo.tm_yday >= (timeinfo_now.tm_yday - timeinfo_now.tm_wday);
        
        NSString *prefix = nil;
        if (dayDiff == 0
            || dayDiff == -1
            || !currentWeek) {
            prefix = [self formatDateForDayRange:date];
        }
        else {
            prefix = [self formatDateForWeekRange:date];
        }
        
        if (timePrefix.length > 0) {
            return [[NSString alloc] initWithFormat:@"%@ %@ %@", prefix, timePrefix, [self formatDateForTimeRange:date]];
        }
        else {
            return [[NSString alloc] initWithFormat:@"%@ %@", prefix, [self formatDateForTimeRange:date]];
        }
    }
}

+ (NSString *)formattedShortDateString:(NSDate *)date {
    
    time_t t = [date timeIntervalSince1970];
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year) {
        return [self formatDateForString:date];
    }
    else {
        
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        BOOL currentWeek = timeinfo.tm_yday >= (timeinfo_now.tm_yday - timeinfo_now.tm_wday);
        
        if (dayDiff == 0) {
            return [self formatDateForTimeRange:date];
        }
        else if (dayDiff == -1
                 || !currentWeek) {
            return [self formatDateForDayRange:date];
        }
        else {
            return [self formatDateForWeekRange:date];
        }
    }
}

+ (NSString *)formatDateForTimeRange:(NSDate *)date {
    
    time_t t = [date timeIntervalSince1970];
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    int hours = timeinfo.tm_hour;
    int minutes = timeinfo.tm_min;
    
    if (isArabic) {
        if (value_dateHas12hFormat) {
            if (hours < 12) {
                return [[NSString alloc] initWithFormat:@"%d:%02d ص", hours == 0 ? 12 : hours, minutes];
            }
            else {
                return [[NSString alloc] initWithFormat:@"%d:%02d م", (hours - 12 == 0) ? 12 : (hours - 12), minutes];
            }
        }
        else {
            return [[NSString alloc] initWithFormat:@"%02d:%02d", hours, minutes];
        }
    }
    else if (isKorean) {
        return [[NSString alloc] initWithFormat:@"%02d:%02d", hours, minutes];
    }
    else {
        if (value_dateHas12hFormat) {
            if (hours < 12) {
                return [[NSString alloc] initWithFormat:@"%d:%02d AM", hours == 0 ? 12 : hours, minutes];
            }
            else {
                return [[NSString alloc] initWithFormat:@"%d:%02d PM", (hours - 12 == 0) ? 12 : (hours - 12), minutes];
            }
        }
        else {
            return [[NSString alloc] initWithFormat:@"%02d:%02d", hours, minutes];
        }
    }
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

+ (NSString *)formatDateForWeekRange:(NSDate *)date {
    
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEEE";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForMonthRange:(NSDate *)date {
    
    static NSDateFormatter* formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"LLLL";
    });
    
    return [formatter stringFromDate:date];
}

+ (NSString *)formatDateForYearRange:(NSDate *)date {
    
    time_t t = [date timeIntervalSince1970];
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    return [[NSString alloc] initWithFormat:@"%04d", timeinfo.tm_year - 100 + 2000];
}

+ (NSString *)formatDateForString:(NSDate *)date {
    
    time_t t = [date timeIntervalSince1970];
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    int day = timeinfo.tm_mday;
    int month = timeinfo.tm_mon + 1;
    int year = timeinfo.tm_year;
    
    if (isArabic) {
        return [[NSString alloc] initWithFormat:@"%d%@%d%@%02d", day, value_date_separator, month, value_date_separator, year - 100];
    }
    else if (isKorean) {
        return [[NSString alloc] initWithFormat:@"%04d년 %d월 %d일", year - 100 + 2000, month, day];
    }
    else {
        if (value_monthFirst) {
            return [[NSString alloc] initWithFormat:@"%d%@%d%@%02d", month, value_date_separator, day, value_date_separator, year - 100];
        }
        else {
            return [[NSString alloc] initWithFormat:@"%d%@%02d%@%02d", day, value_date_separator, month, value_date_separator, year - 100];
        }
    }
}

@end
