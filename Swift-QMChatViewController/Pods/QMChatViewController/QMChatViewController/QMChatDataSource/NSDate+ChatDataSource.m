//
//  NSDate+ChatDataSource.m
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "NSDate+ChatDataSource.h"

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

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate respectOrderedSame:(BOOL)respectOrderedSame {
    
    return respectOrderedSame ?
    ([self compareWithDate:startDate] != NSOrderedAscending &&
     [self compareWithDate:endDate] != NSOrderedDescending) :
    ([self compareWithDate:startDate] == NSOrderedDescending &&
     [self compareWithDate:endDate]  == NSOrderedAscending);
}

@end
