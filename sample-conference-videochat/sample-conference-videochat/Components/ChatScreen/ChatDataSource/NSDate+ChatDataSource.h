//
//  NSDate+ChatDataSource.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ChatDataSource)

- (NSComparisonResult)compareWithDate:(NSDate*)dateToCompareWith;

- (NSDate *)dateAtStartOfDay;
- (NSDate *)dateAtEndOfDay;

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate respectOrderedSame:(BOOL)respectOrderedSame;

@end

NS_ASSUME_NONNULL_END
