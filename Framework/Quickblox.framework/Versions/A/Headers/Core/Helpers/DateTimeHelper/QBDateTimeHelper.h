//
//  QBDateTimeHelper.h
//  Quickblox
//
//  Created by IgorKh on 5/11/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBDateTimeHelper : NSObject

+ (NSDate *)dateFromISO8601:(NSString *)str;

@end
