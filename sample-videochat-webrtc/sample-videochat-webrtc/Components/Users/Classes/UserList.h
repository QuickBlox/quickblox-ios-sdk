//
//  UserList.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 22.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

typedef void(^FetchUsersCompletion)(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error);

@interface UserList : NSObject
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selected;
@property (nonatomic, strong, readonly) NSMutableArray<QBUUser *> *fetched;
@property (nonatomic, assign) BOOL isLoadAll;
@property (nonatomic, assign) NSUInteger currentPage;

- (void)fetchWithPage:(NSUInteger)pageNumber completion:(FetchUsersCompletion)completion;
- (void)fetchNextWithCompletion:(FetchUsersCompletion)completion;
- (void)appendUsers:(NSArray<QBUUser *> *)users;


@end

NS_ASSUME_NONNULL_END
