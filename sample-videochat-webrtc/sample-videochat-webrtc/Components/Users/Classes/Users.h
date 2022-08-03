//
//  Users.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 22.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DownloadUsersCompletion)(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error);

@interface Users : NSObject
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber*, QBUUser*> *users;
@property (nonatomic, strong) NSMutableSet<QBUUser *> *selected;

- (void)usersWithIDs:(NSArray<NSNumber *> *)usersIDs completion:(DownloadUsersCompletion _Nullable)completion;
- (void)appendUsers:(NSArray<QBUUser *> *)users;
@end

NS_ASSUME_NONNULL_END
