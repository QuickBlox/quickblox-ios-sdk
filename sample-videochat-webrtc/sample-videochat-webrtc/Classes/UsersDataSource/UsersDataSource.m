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
@property (strong, nonatomic) NSMutableArray *testUsers;

@end

@implementation UsersDataSource

@dynamic users;

- (QBUUser *)currentUser {
	return [[QBChat instance] currentUser];
}

NSString *const kDefaultPassword = @"x6Bt0VDy5";
NSString *const kUsersKey = @"users";
NSString *const kUserIDKey = @"ID";
NSString *const kFullNameKey = @"fullName";
NSString *const kLoginKey = @"login";
NSString *const kPasswordKey = @"password";

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
        
        _colors =
        @[[UIColor colorWithRed:0.992 green:0.510 blue:0.035 alpha:1.000],
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

- (NSString *)strWithList:(ListOfUsers)list {
    
    switch (list) {
            
        case ListOfUsersQA: return @"QA";
        case ListOfUsersDEV: return @"DEV";
        case ListOfUsersWEB: return @"WEB";
            
        default:return @"PROD";
    }
}

- (void)loadUsersWithList:(ListOfUsers)list {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Users", [self strWithList:list]]
                                                          ofType:@"plist"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *users = dictionary[kUsersKey];
    self.testUsers = [NSMutableArray arrayWithCapacity:users.count];
    [users enumerateObjectsUsingBlock:^(NSDictionary *user, NSUInteger idx, BOOL *stop) {
        
        QBUUser *testUser = [self userWithID:@([user[kUserIDKey] integerValue])
                                       login:user[kLoginKey]
                                    fullName:user[kFullNameKey]
                                    passowrd:user[kPasswordKey]];
        
        [self.testUsers addObject:testUser];
    }];
}

- (NSArray *)users {
    
    return _testUsers.copy;
}

- (QBUUser *)userWithID:(NSNumber *)userID login:(NSString *)login fullName:(NSString *)fullName passowrd:(NSString *)password {
    
    QBUUser *user = [QBUUser user];
    
    user.ID = userID.unsignedIntegerValue;
    user.login = login;
    user.fullName = fullName;
    user.password = password ?:kDefaultPassword;
    
    return user;
}

- (UIColor *)colorAtUser:(QBUUser *)user {
    
    NSUInteger idx = [self.testUsers indexOfObject:user];
    return self.colors[idx];
}

- (NSArray *)usersWithoutMe {
    
    return [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID != %@", @(self.currentUser.ID)]];
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
    return [self.users indexOfObject:user];
}

- (NSArray *)idsWithUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
    
    [users enumerateObjectsUsingBlock:^(QBUUser  *obj, NSUInteger idx, BOOL *stop) {
        
        [ids addObject:@(obj.ID)];
    }];

    return ids.copy;
}

- (NSArray *)usersWithIDS:(NSArray *)ids {

    NSMutableArray *users = [NSMutableArray arrayWithCapacity:ids.count];
    
    [ids enumerateObjectsUsingBlock:^(NSNumber *userID, NSUInteger idx, BOOL *stop) {
        
        QBUUser *user = [self userWithID:userID];
        [users addObject:user];
    }];

    return users;
}

- (NSArray *)usersWithIDSWithoutMe:(NSArray *)ids {
    
    NSMutableArray *users = [self usersWithIDS:ids].mutableCopy;
    [users removeObject:self.currentUser];
    
    return users.copy;
}

- (QBUUser *)userWithID:(NSNumber *)userID {
    
    NSPredicate *userWithIDPredicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
    return [[self.users filteredArrayUsingPredicate:userWithIDPredicate] firstObject];
}

@end
