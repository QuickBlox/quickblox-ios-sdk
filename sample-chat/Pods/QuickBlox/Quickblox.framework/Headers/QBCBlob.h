//
//  QBCBlob.h
//  ContentService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCEntity.h"
#import "QBContentEnums.h"

@class QBCBlobObjectAccess;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBCBlob class interface.
 *  This class represents File in Content module. Limitations: max size of file is 5368709120 bytes (5 GB).
 */
@interface QBCBlob : QBCEntity <NSCoding, NSCopying>

/**
 *  Content type in mime format.
 */
@property (nonatomic, copy, nullable) NSString *contentType;

/**
 *  File name.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 *  Status of the File.
 */
@property (nonatomic, assign) QBCBlobStatus status;

/**
 *  Date when the file upload has been completed.
 */
@property (nonatomic, strong, nullable) NSDate *completedAt;

/**
 *  The size of file in bytes, readonly
 */
@property (nonatomic, assign) NSUInteger size;

/**
 *  File unique identifier.
 */
@property (nonatomic, copy, nullable) NSString *UID;

/**
 *  Last read file time.
 */
@property (nonatomic, strong, nullable) NSDate *lastReadAccessTs;

/**
 *  An instance of BlobObjectAccess.
 */
@property (nonatomic, strong, nullable) QBCBlobObjectAccess *blobObjectAccess;

/**
 *  Coma separated string with file's tags.
 */
@property (nonatomic, copy, nullable) NSString *tags;

/**
 *  File's visibility.
 */
@property (nonatomic, assign) BOOL isPublic;

/**
 *  Set as YES if you want to update blob's file.
 */
@property (nonatomic, assign) BOOL isNew;

/**
 *  Create new blob.
 *
 *  @return New QBCBlob instance
 */
+ (QBCBlob *)blob;

/**
 *  Get file's public url (available within Internet), if blob is public.
 *
 *  @return Public url for file
 */
- (nullable NSString *)publicUrl;

/**
 *  Get file's public url (available within Internet), if blob is public.
 *
 *  @param fileUID File unique identifier
 *
 *  @return Public url to file
 */
+ (nullable NSString *)publicUrlForFileUID:(NSString *)fileUID;

/**
 *  Get file's private url (available only with QuickBlox token), if blob is private.
 *
 *  @return Private url for file
 */
- (nullable NSString *)privateUrl;

/**
 *  Get file's private url (available only with QuickBlox token), if blob is private.
 *
 *  @param fileUID File unique identifier
 *
 *  @return Private url to file
 */
+ (nullable NSString *)privateUrlForFileUID:(NSString *)fileUID;

@end

NS_ASSUME_NONNULL_END
