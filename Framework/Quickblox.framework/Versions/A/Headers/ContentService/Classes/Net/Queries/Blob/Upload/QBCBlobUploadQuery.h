//
//  QBCBlobUploadQuery.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBCBlobUploadQuery : QBCBlobQuery {
	QBCBlob *blobWithWriteAccess;
	NSData *file;
}
@property (nonatomic,retain) QBCBlob *blobWithWriteAccess;
@property (nonatomic,retain) NSData *file;

- (id)initWithBlobWithWriteAccess:(QBCBlob *)blobWithWriteAccess file:(NSData *)data;

@end
