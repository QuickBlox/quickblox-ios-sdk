//
//  UserList.m
//  sample-chat
//
//  Created by Injoit on 22.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserList.h"

const NSUInteger kPerPage = 100;

@interface UserList()
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, QBUUser*> *users;
@end

@implementation UserList
//MARK: - Life Cycle
- (instancetype)initWithNonDisplayedUsers:(NSArray<NSNumber *> *)nonDisplayedUsers {
    self = [super init];
    if (self) {
        self.nonDisplayedUsers = nonDisplayedUsers;
        self.users = [NSMutableDictionary dictionary];
        self.selected = [NSMutableSet set];
        self.isLoadAll = NO;
        self.currentPage = 1;
    }
    return self;
}

//MARK - Setup
- (void)setCurrentPage:(NSUInteger)currentPage {
    _currentPage = currentPage;
    if (_currentPage == 1) {
        [self.users removeAllObjects];
    }
}

//MARK: - Public Methods
- (void)appendUsers:(NSArray<QBUUser *> *)users {
    
    for (QBUUser *user in users) {
        if (self.nonDisplayedUsers && [self.nonDisplayedUsers containsObject:@(user.ID)]) {
            continue;
        }
        self.users[@(user.ID)] = user;
    }
    self.fetched = [self sortUsers:self.users.allValues].mutableCopy;
}

- (void)fetchWithPage:(NSUInteger)pageNumber completion:(FetchUsersCompletion)completion {
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:pageNumber perPage:kPerPage];
    __weak __typeof(self)weakSelf = self;
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc date last_request_at"}
                                   page:page
                           successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isLoadAll = users.count < page.perPage;
        strongSelf.currentPage = pageNumber;
        [strongSelf appendUsers:users];
        if (completion) {
            completion(users, nil);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (response.error.error.code == QBResponseStatusCodeNotFound) {
            strongSelf.isLoadAll = YES;
        }
        if (completion) {
            completion(@[], response.error.error);
        }
    }];
}

- (void)fetchNextWithCompletion:(FetchUsersCompletion)completion {
    NSUInteger nextPage = self.currentPage + 1;
    [self fetchWithPage:nextPage completion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        if (completion) {
            completion(users, error);
        }
    }];
}

//MARK: - Private Methods
- (NSArray <QBUUser *> *)sortUsers:(NSArray <QBUUser *> *)users {
    NSSortDescriptor *usersSortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"lastRequestAt"
                                ascending:NO];
    return [users sortedArrayUsingDescriptors:@[usersSortDescriptor]];
}

@end
