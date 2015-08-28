//
//  UsersPaginator.m
//  sample-users
//
//  Created by Quickblox Team on 6/11/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "UsersPaginator.h"
#import <QuickBlox/QuickBlox.h>

@implementation UsersPaginator

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // Load files
    //
    __weak __typeof(self)weakSelf = self;
    
    QBGeneralResponsePage *responsePage = [QBGeneralResponsePage responsePageWithCurrentPage:page perPage:pageSize];
    
    [QBRequest usersForPage:responsePage successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        [weakSelf receivedResults:users total:page.totalEntries];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error: %@", response.error);
        [weakSelf receivedResults:nil total:0];
    }];
}

@end
