//
//  DateTimeHelper.h
//  Quickblox
//
//  Created by IgorKh on 4/17/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeHelper : NSObject

+ (NSDate *)dateFromISO8601:(NSString *)str;

@end
