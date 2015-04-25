//
//  BlobAnswer.h
//  ContentService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAnswer.h"

@class QBCBlobObjectAccessAnswer;
@class QBCBlob;


@interface QBCBlobAnswer : EntityAnswer {
@protected
	QBCBlob* blob;
    QBCBlobObjectAccessAnswer* blobObjectAccessAnswer;
}

@property (nonatomic, readonly) QBCBlob* blob;
@property (nonatomic, retain) QBCBlobObjectAccessAnswer* blobObjectAccessAnswer;

@end
