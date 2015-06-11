//
//  QBCFileUploadTask.h
//  ContentService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBCBlob;

@interface QBCFileUploadTask : Task {
	NSData *data;
	NSString *contentType;
	NSString *fileName;
	QBCBlob *blob;
    BOOL isPublic;
}
@property (nonatomic,retain) NSString *contentType;
@property (nonatomic,retain) NSString *fileName;
@property (nonatomic,retain) NSData *data;
@property (nonatomic,retain) QBCBlob *blob;
@property (nonatomic) BOOL isPublic;

@end