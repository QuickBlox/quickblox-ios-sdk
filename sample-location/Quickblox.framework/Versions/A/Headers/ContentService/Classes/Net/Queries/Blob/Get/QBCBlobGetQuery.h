//
//  QBBlobGetQuery.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBCBlobGetQuery : QBCBlobQuery {
@protected
	NSUInteger blobId;
    PagedRequest *pagedRequest;
    
    BOOL isMultipleGet;
    BOOL isTaggedGet;
}
@property (nonatomic,readonly) NSUInteger blobId;
@property (nonatomic, readonly) PagedRequest *pagedRequest;

- (id)initWithBlobId:(NSUInteger)blobid;
- (id)initWithPagedRequest:(PagedRequest *)pagedRequest isTaggedGet:(BOOL)isTaggedGet;

@end
