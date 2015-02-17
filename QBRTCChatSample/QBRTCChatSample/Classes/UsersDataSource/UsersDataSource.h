//
//  UsersDataSource.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersDataSource : NSObject

@property (strong, nonatomic, readonly) NSArray *users;

+ (instancetype)instance;
- (UIColor *)colorAtUser:(QBUUser *)user;

@end
