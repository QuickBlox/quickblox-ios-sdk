//
//  QBCBlobUpdateQuery.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBCBlobUpdateQuery : QBCBlobQuery {
@protected
	QBCBlob *blob;
}
@property (nonatomic,readonly) QBCBlob *blob;

-(id)initWithBlob:(QBCBlob *)blob;

@end
