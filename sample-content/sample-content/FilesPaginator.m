//
//  FilesPaginator.m
//  sample-content
//
//  Created by Igor Khomenko on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "FilesPaginator.h"
#import <QuickBlox/QuickBlox.h>

@implementation FilesPaginator

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // Load files
    //
    __weak __typeof(self)weakSelf = self;
    
    QBGeneralResponsePage *responsePage = [QBGeneralResponsePage responsePageWithCurrentPage:page perPage:pageSize];
    [QBRequest blobsForPage:responsePage successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
        [weakSelf receivedResults:blobs total:page.totalEntries];
        
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error: %@", response.error);
        [weakSelf receivedResults:nil total:0];
    }];
}

@end
