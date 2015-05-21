//
//  QBCBlobResult.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBResult.h"

/** QBCBlobResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get file. Represent a single blob. */

@class QBCBlob;

@interface QBCBlobResult : QBResult{
@protected
	QBCBlob* blob;
}

/** An instance of  QBCBlob */
@property (nonatomic,readonly) QBCBlob* blob;

@end
