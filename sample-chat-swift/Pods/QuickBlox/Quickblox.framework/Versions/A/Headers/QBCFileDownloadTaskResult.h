//
//  QBCFileDownloadTaskResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/15/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskResult.h"

@class QBCBlob;

/** QBCFileDownloadTaskResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for download file. */

@interface QBCFileDownloadTaskResult : TaskResult {
@private
	NSData *file;
    QBCBlob *blob;
}

/** File.*/
@property (nonatomic,readonly) NSData *file;

/** Blob.*/
@property (nonatomic,readonly) QBCBlob *blob;

+ (QBCFileDownloadTaskResult *)resultWithFile:(NSData *)file blob:(QBCBlob *)blob;

@end
