//
//  UsersDataSource.h
//  LoginComponent
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

@interface UsersDataSource : NSObject <UITableViewDataSource>

@property (copy, nonatomic, readonly) NSArray <QBUUser *> *selectedUsers;

- (void)selectUserAtIndexPath:(NSIndexPath *)indexPath;

- (QBUUser *)userWithID:(NSUInteger)ID;
- (NSArray <NSNumber *> *)idsForUsers:(NSArray <QBUUser *>*)users;
- (NSArray <QBUUser *> *)usersSortedByFullName;
- (NSArray <QBUUser *> *)usersSortedByLastSeen;
- (void)updateUsers:(NSArray<QBUUser *> *)users;

@end

NS_ASSUME_NONNULL_END
