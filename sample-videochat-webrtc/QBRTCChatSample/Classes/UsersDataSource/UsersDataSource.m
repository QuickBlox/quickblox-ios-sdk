//
//  UsersDataSource.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "UsersDataSource.h"

@interface UsersDataSource()

@property (strong, nonatomic, readonly) NSArray *colors;

@end

@implementation UsersDataSource

NSString *const kDefaultPassword = @"x6Bt0VDy5";

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        QBUUser *user1 = [QBUUser user];
        user1.ID = 2077886;
        user1.login = @"@user1";
        user1.fullName = @"User 1";
        user1.password = kDefaultPassword;
        
        QBUUser *user2 = [QBUUser user];
        user2.ID = 2077894;
        user2.login = @"@user2";
        user2.fullName = @"User 2";
        user2.password = kDefaultPassword;
        
        QBUUser *user3 = [QBUUser user];
        user3.ID = 2077896;
        user3.login = @"@user3";
        user3.fullName = @"User 3";
        user3.password = kDefaultPassword;
        
        QBUUser *user4 = [QBUUser user];
        user4.ID = 2077897;
        user4.login = @"@user4";
        user4.fullName = @"User 4";
        user4.password = kDefaultPassword;
        
        QBUUser *user5 = [QBUUser user];
        user5.ID = 2077900;
        user5.login = @"@user5";
        user5.fullName = @"User 5";
        user5.password = kDefaultPassword;
        
        QBUUser *user6 = [QBUUser user];
        user6.ID = 2077901;
        user6.login = @"@user6";
        user6.fullName = @"User 6";
        user6.password = kDefaultPassword;
        
        QBUUser *user7 = [QBUUser user];
        user7.ID = 2077902;
        user7.login = @"@user7";
        user7.fullName = @"User 7";
        user7.password = kDefaultPassword;
        
        QBUUser *user8 = [QBUUser user];
        user8.ID = 2077904;
        user8.login = @"@user8";
        user8.fullName = @"User 8";
        user8.password = kDefaultPassword;
        
        QBUUser *user9 = [QBUUser user];
        user9.ID = 2077906;
        user9.login = @"@user9";
        user9.fullName = @"User 9";
        user9.password = kDefaultPassword;
        
        QBUUser *user10 = [QBUUser user];
        user10.ID = 2077907;
        user10.login = @"@user10";
        user10.fullName = @"User 10";
        user10.password = kDefaultPassword;
        
        _users = @[user1, user2, user3, user4, user5, user6, user7, user8, user9, user10];
        
        _colors =  @[
                     [UIColor colorWithRed:0.992 green:0.510 blue:0.035 alpha:1.000],
                     [UIColor colorWithRed:0.039 green:0.376 blue:1.000 alpha:1.000],
                     [UIColor colorWithRed:0.984 green:0.000 blue:0.498 alpha:1.000],
                     [UIColor colorWithRed:0.204 green:0.644 blue:0.251 alpha:1.000],
                     [UIColor colorWithRed:0.580 green:0.012 blue:0.580 alpha:1.000],
                     [UIColor colorWithRed:0.396 green:0.580 blue:0.773 alpha:1.000],
                     [UIColor colorWithRed:0.765 green:0.000 blue:0.086 alpha:1.000],
                     [UIColor colorWithWhite:0.537 alpha:1.000],
                     [UIColor colorWithRed:0.786 green:0.706 blue:0.000 alpha:1.000],
                     [UIColor colorWithRed:0.740 green:0.624 blue:0.797 alpha:1.000]];
    }
    
    return self;
}

- (UIColor *)colorAtUser:(QBUUser *)user {
    
    NSUInteger idx = [self.users indexOfObject:user];
    
    if (idx != NSNotFound) {
        
        return self.colors[idx];
    }
    else {
        
        return nil;
    }
}

@end
