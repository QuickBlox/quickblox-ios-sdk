//
//  UsersDataSource.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 06/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

@interface UsersDataSource : NSObject <UITableViewDataSource>

//@property (copy, nonatomic, readonly) NSArray <QBUUser *> *roomUsers;
@property (copy, nonatomic, readonly) NSArray <QBUUser *> *selectedUsers;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCurrentUser:(QBUUser *)currentUser;

- (BOOL)setUsers:(NSArray <QBUUser *> *)users;

- (void)selectUserAtIndexPath:(NSIndexPath *)indexPath;

- (QBUUser *)userWithID:(NSUInteger)ID;
- (NSArray <NSNumber *> *)idsForUsers:(NSArray <QBUUser *>*)users;
- (NSArray <QBUUser *> *)usersSortedByFullName;
- (NSArray <QBUUser *> *)usersSortedByLastSeen;

@end

NS_ASSUME_NONNULL_END
