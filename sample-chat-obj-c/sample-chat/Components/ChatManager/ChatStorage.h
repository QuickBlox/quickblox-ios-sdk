//
//  ChatStorage.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatStorage : NSObject

@property(nonatomic, strong) NSMutableArray<QBChatDialog *> *dialogs;
@property(nonatomic, strong) NSMutableArray<QBUUser *> *users;

- (void)clear;
- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID;
- (QBChatDialog *)dialogWithID:(NSString *)dialogID;
- (NSArray<QBChatDialog*> *)dialogsSortByUpdatedAt;
- (QBChatDialog *)updateDialog:(QBChatDialog *)dialog;
- (void)updateDialogs:(NSArray<QBChatDialog*> *)dialogs;
- (void)deleteDialogWithID:(NSString *)ID;
- (QBUUser *)userWithID:(NSUInteger)ID;
- (void)updateUsers:(NSArray<QBUUser *> *)users;
- (NSArray<QBUUser*> *)usersWithDialogID:(NSString *)dialogID;
- (NSArray<QBUUser*> *)sortedAllUsers;

@end

NS_ASSUME_NONNULL_END
