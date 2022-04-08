//
//  UserList.h
//  sample-chat
//
//  Created by Injoit on 22.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FetchUsersCompletion)(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error);

@interface UserList : NSObject
- (instancetype)initWithNonDisplayedUsers:(NSArray<NSNumber *> *)nonDisplayedUsers;

@property (strong, nonatomic) NSArray<NSNumber *> *nonDisplayedUsers;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selected;
@property (nonatomic, strong) NSMutableArray<QBUUser *> *fetched;
@property (nonatomic, assign) BOOL isLoadAll;
@property (nonatomic, assign) NSUInteger currentPage;

- (void)fetchWithPage:(NSUInteger)pageNumber completion:(FetchUsersCompletion)completion;
- (void)fetchNextWithCompletion:(FetchUsersCompletion)completion;
- (void)appendUsers:(NSArray<QBUUser *> *)users;


@end

NS_ASSUME_NONNULL_END
