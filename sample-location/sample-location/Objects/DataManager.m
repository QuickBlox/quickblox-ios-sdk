//
//  DataManager.m
//  sample-location
//
//  Created by Quickblox Team on 9/19/12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "DataManager.h"

NSString * const GeoDataManagerDidUpdateData = @"GeoDataManagerDidUpdateData";

@implementation DataManager

+ (instancetype)instance
{
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (void)saveCheckins:(NSArray *)checkins
{
    _checkins = checkins;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GeoDataManagerDidUpdateData object:nil];
}

- (void)saveCurrentUser:(QBUUser *)user
{
    _currentUser = user;
}

@end