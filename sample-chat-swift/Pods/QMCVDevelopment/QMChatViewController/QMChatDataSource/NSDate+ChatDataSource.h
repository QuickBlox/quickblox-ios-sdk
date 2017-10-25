//
//  NSDate+ChatDataSource.h
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ChatDataSource)

- (NSComparisonResult)compareWithDate:(NSDate*)dateToCompareWith;

- (NSDate *)dateAtStartOfDay;
- (NSDate *)dateAtEndOfDay;

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate respectOrderedSame:(BOOL)respectOrderedSame;

@end
