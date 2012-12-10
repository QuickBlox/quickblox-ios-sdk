//
//  QBMEventGetQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBMEventGetQuery : QBMEventQuery{
    NSUInteger eventID;
    PagedRequest *pagedRequest;

    BOOL isMultipleGet;
    BOOL isPullGet;
}
@property (nonatomic) NSUInteger eventID;
@property (nonatomic, readonly) PagedRequest *pagedRequest;

- (id)initWithPagedRequest:(PagedRequest *)_pagedRequest;
- (id)initWithEventID:(NSUInteger)geodataID;
- (id)initForPullEvents;

@end
