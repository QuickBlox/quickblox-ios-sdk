//
//  QBCFileUploadTaskResult.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskResult.h"

@class QBCBlob;

/** QBCFileUploadTaskResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for upload file. */

@interface QBCFileUploadTaskResult : TaskResult {
@private
	QBCBlob *uploadedBlob;
}

/** An instance of QBCBlob.*/
@property (nonatomic,readonly) QBCBlob *uploadedBlob;

+ (QBCFileUploadTaskResult *)resultWithBlob:(QBCBlob *)uploadedBlob;

@end