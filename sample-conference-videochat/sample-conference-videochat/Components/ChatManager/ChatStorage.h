//
//  ChatStorage.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatStorage : NSObject

typedef void(^UpdatedStorageCompletion)(NSError * _Nullable error);

@property(nonatomic, strong) NSMutableArray<QBChatDialog *> *dialogs;
@property(nonatomic, strong) NSMutableArray<QBUUser *> *users;

- (void)clear;
- (QBChatDialog *)dialogWithID:(NSString *)dialogID;
- (NSArray<QBChatDialog*> *)dialogsSortByUpdatedAt;
- (QBChatDialog *)updateDialog:(QBChatDialog *)dialog;
- (void)updateDialogs:(NSArray<QBChatDialog*> *)dialogs completion:(nullable UpdatedStorageCompletion)completion;
- (void)deleteDialogWithID:(NSString *)ID;
- (QBUUser *)userWithID:(NSUInteger)ID;
- (void)updateUsers:(NSArray<QBUUser *> *)users;
- (NSArray<QBUUser*> *)usersWithDialogID:(NSString *)dialogID;
- (NSArray<QBUUser*> *)sortedAllUsers;
- (NSSet<QBUUser*> *)fetchAllUsersIDs;

@end

NS_ASSUME_NONNULL_END
