//
//  DataManager.h
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents application storage. We store all users, rooms & current user entity;
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSMutableArray *rooms;
@property (nonatomic, retain) QBUUser *currentUser;

+(DataManager *)shared;

- (NSMutableArray *)chatHistoryWithOpponentID:(NSUInteger)opponentID;
- (void)saveMessage:(id)message toHistoryWithOpponentID:(NSUInteger)opponentID;

@end
