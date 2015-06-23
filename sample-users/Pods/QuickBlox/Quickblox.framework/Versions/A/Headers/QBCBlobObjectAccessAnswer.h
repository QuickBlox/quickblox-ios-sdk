//
//  QBCBlobObjectAccessAnswer.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAnswer.h"

@class QBCBlobObjectAccess;

@interface QBCBlobObjectAccessAnswer : EntityAnswer {
@protected
    QBCBlobObjectAccess* blobObjectAccess;
	NSMutableString* paramsBuffer;
}
@property (nonatomic, retain) NSMutableString* paramsBuffer;
@property (nonatomic, readonly) QBCBlobObjectAccess* blobObjectAccess;

@end
