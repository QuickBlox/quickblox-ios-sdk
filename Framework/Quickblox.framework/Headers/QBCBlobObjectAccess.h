//
//  QBCBlobObjectAccess.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBCEntity.h"
#import "QBContentEnums.h"

/** QBCBlobObjectAccess class declaration. */
/** Overview */
/** This class represents entity that uses for upload file to server. */

@interface QBCBlobObjectAccess : QBCEntity <NSCoding, NSCopying> {
	NSUInteger blobID;
	enum QBCBlobObjectAccessType type;
	NSDate *expires;
	NSString *urlWithParams;
	NSDictionary *params;
	NSURL *url;
}

/** Blob ID */
@property (nonatomic) NSUInteger blobID;

/** Link access type */
@property (nonatomic) enum QBCBlobObjectAccessType type;

/** Reference expiration time */
@property (nonatomic,retain, QB_NULLABLE_PROPERTY) NSDate* expires;

/** Url with params. Use it for upload file */
@property (nonatomic,retain, QB_NULLABLE_PROPERTY) NSString* urlWithParams;

/** Params. Use them for upload file */
@property (nonatomic,retain, QB_NULLABLE_PROPERTY) NSDictionary* params;

/** Url with params. Use it for upload file */
@property (nonatomic,retain, QB_NULLABLE_PROPERTY) NSURL* url;

/** Check link expiration date
 @return YES if link is expired, otherwise NO
 */
@property (nonatomic,readonly) BOOL expired;

@end
