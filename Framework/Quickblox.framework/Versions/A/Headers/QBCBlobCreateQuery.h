//
//  QBCBlobCreateQuery.h
//  ContentService
//
//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCBlobQuery.h"

@class QBCBlob;

@interface QBCBlobCreateQuery : QBCBlobQuery {
@protected
	QBCBlob *blob;
}

@property (nonatomic,readonly) QBCBlob *blob;

-(id)initWithBlob:(QBCBlob *)blob;

@end