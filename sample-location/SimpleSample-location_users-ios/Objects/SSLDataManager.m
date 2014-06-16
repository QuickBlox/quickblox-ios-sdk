//
//  DataManager.m
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/19/12.
//
//

#import "SSLDataManager.h"

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
}

- (void)saveCurrentUser:(QBUUser *)user
{
    _currentUser = user;
}

@end