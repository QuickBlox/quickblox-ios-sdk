//
//  ConnectionManager.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/27/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject

+ (instancetype)instance;

- (void)logInWithUser:(QBUUser *)user completion:(void (^)(BOOL success, NSString *errorMessage))completion;
- (void)logOut;


@end

@interface QBUUser (ConnectionManager)

- (NSUInteger)index;
- (UIColor *)color;

@end