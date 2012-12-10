//
//  QBCBlobCompleteQuery.h
//  ContentService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBCBlobCompleteQuery : QBCBlobQuery {
@private
	NSUInteger blobId;
    NSUInteger size;
}
@property (nonatomic,readonly) NSUInteger blobId;
@property (nonatomic,readonly) NSUInteger size;

-(id)initWithBlobId:(NSUInteger)blobid size:(NSUInteger)size;

@end
