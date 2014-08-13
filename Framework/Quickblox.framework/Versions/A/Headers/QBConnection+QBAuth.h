//
//  QBConnection+Auth.h
//  Quickblox
//
//  Created by Andrey Kozlov on 09/01/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBConnection.h"

@interface QBConnection (QBAuth)

+ (QBConnection *)authSessionConnection;
+ (QBConnection *)authUserConnection;

#pragma mark - Establish connection methods to receive session token

+ (void)connectWithCompletionBlock:(void (^)(BOOL success))completionBlock;
+ (void)connectUsingUserLogin:(NSString *)login password:(NSString *)password withCompletionBlock:(void (^)(BOOL success))completionBlock;
// TODO: add other wariants of getting session token

+ (void)disconnectWithCompletionBlock:(void (^)(BOOL success))completionBlock;

@end
