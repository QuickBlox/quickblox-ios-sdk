//
//  DateUtils.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateUtils : NSObject

/**
 *  Formatted last seen string.
 *
 *  @param date       date to make formatted string from
 *  @param timePrefix time prefix between date and time
 *
 *  @return string with formatted full date (used for last seen)
 */
+ (NSString *)formattedLastSeenString:(NSDate *)date withTimePrefix:(nullable NSString *)timePrefix;

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
 *  Formatted string for date.
 *
 *  @param date         date to make formatted string from
 *
 *  @return string with base date format (e.g. 11/08/2011)
 */
+ (NSString *)formatDateForString:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
