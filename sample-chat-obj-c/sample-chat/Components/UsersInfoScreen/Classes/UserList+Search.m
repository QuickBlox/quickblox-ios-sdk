//
//  UserList+Search.m
//  sample-chat
//
//  Created by Injoit on 27.10.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserList+Search.h"
const NSUInteger searchPerPage = 10;

@implementation UserList (Search)
//MARK: - Public Methods
- (void)searchWithName:(NSString *)name page:(NSUInteger)pageNumber completion:(FetchUsersCompletion)completion {
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:pageNumber perPage:searchPerPage];
    __weak __typeof(self)weakSelf = self;
    [QBRequest usersWithFullName:name
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

- (void)searchNextWithName:(NSString *)name completion:(FetchUsersCompletion)completion {
    NSUInteger nextPage = self.currentPage + 1;
    [self searchWithName:name page:nextPage completion:^(NSArray<QBUUser *> * _Nullable users, NSError * _Nullable error) {
        if (completion) {
            completion(users, error);
        }
    }];
}

@end
