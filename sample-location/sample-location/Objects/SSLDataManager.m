//
//  DataManager.m
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/19/12.
//
//

#import "SSLDataManager.h"

NSString * const SSLGeoDataManagerDidUpdateData = @"SSLGeoDataManagerDidUpdateData";

@implementation SSLDataManager

+ (instancetype)instance
{
    static SSLDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (void)saveCheckins:(NSArray *)checkins
{
    _checkins = checkins;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSLGeoDataManagerDidUpdateData object:nil];
}

- (void)saveCurrentUser:(QBUUser *)user
{
    _currentUser = user;
}

@end