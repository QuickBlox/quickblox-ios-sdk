//
//  QBCBlob.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBCEntity.h"
#import "QBContentEnums.h"

@class QBCBlobObjectAccess;

/** QBCBlob class declaration. */
/** Overview */
/** This class represents File in Content module. Limitations: max size of file is 5368709120 bytes (5 GB). */

@interface QBCBlob : QBCEntity <NSCoding, NSCopying>
{
	NSString *contentType;          
	NSString *name;                 
	enum QBCBlobStatus status;       
	NSDate *completedAt;            
	NSUInteger size;                
	NSString *UID; 
    NSDate *lastReadAccessTs;
    NSString *tags;
    BOOL isPublic;
    BOOL isNew;
    
    QBCBlobObjectAccess *blobObjectAccess;
}

/** Content type in mime format */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString* contentType;

/** File name */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString* name;

/** Status of the File */
@property (nonatomic) enum QBCBlobStatus status;

/** Date when the file upload has been completed */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate* completedAt;

/** The size of file in bytes, readonly */
@property (nonatomic) NSUInteger size;

/** File unique identifier */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString* UID;

/** Last read file time */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *lastReadAccessTs;

/** An instance of  BlobObjectAccess */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) QBCBlobObjectAccess *blobObjectAccess;

/** Coma separated string with file's tags */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *tags;

/** File's visibility */
@property (nonatomic) BOOL isPublic;

/** Set as YES if you want to updated blob's file */
@property (nonatomic) BOOL isNew;

/** Create new blob
 @return New instance of QBCBlob
 */
+ (QB_NONNULL QBCBlob *)blob;


/** Get file's public url (available within Internet), if blob is public.
 @return Public url to file
 */
- (QB_NULLABLE NSString *)publicUrl;

/** Get file's public url (available within Internet) by ID.
 @return Public url to file
 */
+ (QB_NULLABLE NSString *)publicUrlForID:(NSUInteger)ID;


/** Get file's private url (available only with QuickBlox token), if blob is private.
 @return Private url to file
 */
- (QB_NULLABLE NSString *)privateUrl;

/** Get file's private url (available only with QuickBlox token) by ID.
 @return Private url to file
 */
+ (QB_NULLABLE NSString *)privateUrlForID:(NSUInteger)ID;


#pragma mark -
#pragma mark Converters

+ (enum QBCBlobStatus)statusFromString:(QB_NULLABLE NSString *)status;
+ (QB_NULLABLE NSString *)statusToString:(enum QBCBlobStatus)status;

@end
