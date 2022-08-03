//
//  Users.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 22.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "Users.h"

@interface Users()
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, QBUUser*> *users;
@end

@implementation Users
//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _users = [NSMutableDictionary dictionary];
        _selected = [NSMutableSet set];
    }
    return self;
}

//MARK: - Public Methods
- (void)usersWithIDs:(NSArray<NSNumber *> *)usersIDs completion:(DownloadUsersCompletion _Nullable)completion {
    NSMutableDictionary<NSNumber *, QBUUser *> *members = @{}.mutableCopy;
    NSMutableArray<NSString *> *newUsersIDs = @[].mutableCopy;
    for (NSNumber *userID in usersIDs) {
        QBUUser *user = self.users[userID];
        if (user) {
            members[userID] = user;
        } else {
            [newUsersIDs addObject:userID.stringValue];
        }
    }

    if (!newUsersIDs.count) {
        if (completion) {
            completion(members.allValues, nil);
        }
        return;
    }

    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
    __weak __typeof(self)weakSelf = self;
    [QBRequest usersWithIDs:newUsersIDs.copy
                       page:page
               successBlock:^(QBResponse * _Nonnull response,
                              QBGeneralResponsePage * _Nonnull page,
                              NSArray<QBUUser *> * _Nonnull users) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf appendUsers:users];
        if (completion) {
            completion([users arrayByAddingObjectsFromArray:members.allValues], nil);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(members.allValues, response.error.error);
        }
    }];
}

- (void)appendUsers:(NSArray<QBUUser *> *)users {
    for (QBUUser *user in users) {
        self.users[@(user.ID)] = user;
    }
}

@end
