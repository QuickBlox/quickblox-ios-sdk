//
//  QBCBlobDeleteQuery.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCBlobQuery.h"

@interface QBCBlobDeleteQuery : QBCBlobQuery {
@private
	NSUInteger blobId;
}
@property (nonatomic,readonly) NSUInteger blobId;

-(id)initWithBlobId:(NSUInteger)blobid;

@end
