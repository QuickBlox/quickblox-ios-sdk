//
//  QBCBlobObjectAccessResult.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBResult.h"

@class QBCBlobObjectAccess;

/** QBCBlobObjectAccessResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for get file as BlobObjectAccess with read access */
@interface QBCBlobObjectAccessResult : QBResult{
}

/** An instance of QBCBlobObjectAccess.*/
@property (nonatomic,readonly) QBCBlobObjectAccess* blobObjectAccess;

@end
