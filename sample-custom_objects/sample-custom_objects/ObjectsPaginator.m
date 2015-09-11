//
//  ObjectsPaginator.m
//  sample-custom_objects
//
//  Created by Quickblox Team on 6/10/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "ObjectsPaginator.h"
#import "Storage.h"
#import <QuickBlox/QuickBlox.h>


@implementation ObjectsPaginator{
    NSUInteger _totalCount;
}

- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    if(page == 1){
        [self requestMoviesTotalCountWithOriginalRequestPage:page pageSize:pageSize];
    }else{
        [self requestMoviesWithPage:page pageSize:pageSize];
    }
}


#pragma mark
#pragma mark Private

- (void)requestMoviesWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    __weak __typeof(self)weakSelf = self;
    
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    if(page > 1){
        [requestParameters setObject:@((page-1)*pageSize) forKey:@"skip"];
    }
    [requestParameters setObject:@(pageSize) forKey:@"limit"];
    
    [QBRequest objectsWithClassName:kMovieClassName extendedRequest:requestParameters
                       successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                           [weakSelf receivedResults:objects total:_totalCount];
                       } errorBlock:^(QBResponse *response) {
                           NSLog(@"Response error: %@", response.error);
                           [weakSelf receivedResults:nil total:0];
                       }];
}

- (void)requestMoviesTotalCountWithOriginalRequestPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    __weak __typeof(self)weakSelf = self;
    
    [QBRequest countObjectsWithClassName:kMovieClassName extendedRequest:nil
                            successBlock:^(QBResponse *response, NSUInteger count) {
                                _totalCount = count;
                                
                                [weakSelf requestMoviesWithPage:page pageSize:pageSize];
                            } errorBlock:^(QBResponse *response) {
                                NSLog(@"Response error:%@", response.error);
                            }];
}

@end
