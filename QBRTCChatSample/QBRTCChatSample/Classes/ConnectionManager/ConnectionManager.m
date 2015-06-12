//
//  ConnectionManager.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ConnectionManager.h"
#import "UsersDataSource.h"

const NSTimeInterval kChatPresenceTimeInterval = 45;

@interface ConnectionManager()

<QBChatDelegate>

@property (copy, nonatomic) void(^chatLoginCompletionBlock)(BOOL error);
@property (strong, nonatomic) QBUUser *me;
@property (strong, nonatomic) QBBackgroundTimer *presenceTimer;

@end

@implementation ConnectionManager

@dynamic users;
@dynamic usersWithoutMe;

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - Login / Logout

- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL error))completion {
    
    [QBChat.instance loginWithUser:user];
    [QBChat.instance addDelegate:self];
    
    self.me = user;
    
    if (QBChat.instance.isLoggedIn) {
        completion(NO);
    }
    else {
        
        self.chatLoginCompletionBlock = completion;
    }
}

- (void)logOut {
    
    [self.presenceTimer invalidate];
    self.presenceTimer = nil;
    if ([QBChat.instance isLoggedIn]) {
        
        [QBChat.instance logout];
    }
    
    self.me = nil;
}

#pragma mark - QBChatDelegate

- (void)chatDidNotLogin {
    
    if (self.chatLoginCompletionBlock) {
        self.chatLoginCompletionBlock(YES);
        self.chatLoginCompletionBlock = nil;
    }
}

- (void)chatDidFailWithError:(NSInteger)code {
    
    if (self.chatLoginCompletionBlock) {
        self.chatLoginCompletionBlock(YES);
        self.chatLoginCompletionBlock = nil;
    }
}

- (void)chatDidLogin {
    
    __weak __typeof(self)weakSelf = self;
    
    self.presenceTimer =
    [[QBBackgroundTimer alloc] initAndSheduleWithTimeInterval:kChatPresenceTimeInterval
                                                     userInfo:nil
                                                      repeats:YES timerDidFire:^{
                                                          
                                                          [[QBChat instance] sendPresence];
                                                          
                                                      } expirationHandler:^{
                                                          
                                                          [weakSelf.presenceTimer invalidate];
                                                          weakSelf.presenceTimer = nil;
                                                          
                                                      }];
    
    if (self.chatLoginCompletionBlock) {
        self.chatLoginCompletionBlock(NO);
        self.chatLoginCompletionBlock = nil;
    }
}

#pragma mark - Public

- (NSArray *)usersWithIDS:(NSArray *)ids {
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:ids.count];
    [ids enumerateObjectsUsingBlock:^(NSNumber *userID, NSUInteger idx, BOOL *stop){
        
        QBUUser *user = [self userWithID:userID];
        [users addObject:user];
    }];
    
    return users;
}

- (NSArray *)idsWithUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
    [users enumerateObjectsUsingBlock:^(QBUUser  *obj, NSUInteger idx,BOOL *stop){
        [ids addObject:@(obj.ID)];
    }];
    
    return ids;
}

#pragma mark - Users Datasource

- (NSArray *)users {
    
    return UsersDataSource.instance.users;
}

- (NSArray *)usersWithoutMe {
    
    NSMutableArray *usersWithoutMe = UsersDataSource.instance.users.mutableCopy;
    [usersWithoutMe removeObject:self.me];
    
    return usersWithoutMe;
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
    
    return [self.users indexOfObject:user];
}

- (UIColor *)colorAtUser:(QBUUser *)user {
    
    return [UsersDataSource.instance colorAtUser:user];
}

- (QBUUser *)userWithID:(NSNumber *)userID {
    
    __block QBUUser *resultUser = nil;
    [self.users enumerateObjectsUsingBlock:^(QBUUser *user, NSUInteger idx, BOOL *stop) {
        
        if (user.ID == userID.integerValue) {
            
            resultUser =  user;
            *stop = YES;
        }
    }];
    
    return resultUser;
}

@end

@implementation QBUUser (ConnectionManager)

- (NSUInteger)index {
    
    NSUInteger idx = [ConnectionManager.instance indexOfUser:self];
    return idx;
}

- (UIColor *)color {
    
    UIColor *color = [ConnectionManager.instance colorAtUser:self];
    return color;
}

@end
