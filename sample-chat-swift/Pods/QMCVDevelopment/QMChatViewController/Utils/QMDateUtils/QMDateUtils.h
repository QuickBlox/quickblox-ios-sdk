//
//  QMDateUtils.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/19/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMDateUtils : NSObject

/**
 *  Formatted string for date.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with formatted full date (used in chat sections names)
 */
+ (NSString *)formattedStringFromDate:(NSDate *)date;

/**
 *  Formatted last seen string.
 *
 *  @param date       date to make formatted string from
 *  @param timePrefix time prefix between date and time
 *
 *  @return string with formatted full date (used for last seen)
 */
+ (NSString *)formattedLastSeenString:(NSDate *)date withTimePrefix:(NSString *)timePrefix;

/**
 *  Formatted short date string.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with short date format (e.g. time for today, Yesterday, week day name or full date)
 */
+ (NSString *)formattedShortDateString:(NSDate *)date;

#pragma mark - custom formatting

/**
 *  Formatted string for time of date.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with basic time localized format (e.g. 11:10 AM)
 */
+ (NSString *)formatDateForTimeRange:(NSDate *)date;

/**
 *  Formatted string for day of date.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with basic day localized format (e.g. Yesterday, Today, Tomorrow)
 */
+ (NSString *)formatDateForDayRange:(NSDate *)date;

/**
 *  Formatted string for week of date.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with basic week localized format (e.g. Monday, Tuesday, Wednesday)
 */
+ (NSString *)formatDateForWeekRange:(NSDate *)date;

/**
 *  Formatted string for month of date.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with basic month localized format (e.g. September, October, November)
 */
+ (NSString *)formatDateForMonthRange:(NSDate *)date;

/**
 *  Formatted string for year of date.
 *
 *  @param date date to make formatted string from
 *
 *  @return string with basic year format (e.g. 2016)
 */
+ (NSString *)formatDateForYearRange:(NSDate *)date;

/**
 *  Formatted string for date.
 *
 *  @param date         date to make formatted string from
 *
 *  @return string with base date format (e.g. 11/08/2011)
 */
+ (NSString *)formatDateForString:(NSDate *)date;

/**
 *  Formatted string for short date.
 *
 *  @param date         date to make formatted string from
 *
 *  @return string with base date format (e.g. 11.08.11)
 */
+ (NSString *)formatShortDateForString:(NSDate *)date;

@end
