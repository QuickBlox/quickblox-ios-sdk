//
//  NSPersistentStore+QMCDRecord.h
//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "QMCDRecordDeprecated.h"

@interface NSPersistentStore (QMCDRecord)

/**
 Default location and filename for the persistent store created by QMCDRecord.
 
 This is usually `/Users/MyAccount/Library/Application Support/MyAppName/CoreDataStore.sqlite`.

 @return URL for the default persistent store file.

 @since Available in v2.3 and later.
 */
+ (NSURL *) QM_defaultLocalStoreUrl;

/**
 Given the provided filename, return a URL to the default location for storing persistent stores. By default this is in the application support directory, ie: `/Users/${USER}/Library/Application Support/${MY_APPLICATION_NAME}/{$storeFileName}`

 @param storeFileName Filename that you'd like to use. This should include a valid file extension.

 @return URL to proposed persistent store file.

 @since Available in v2.3 and later.
 */
+ (NSURL *) QM_fileURLForStoreName:(NSString *)storeFileName;

/**
 Uses the result of `+ QM_fileURLForStoreName:`, but returns nil if the store file does not exist at the returned URL.

 @param storeFileName Filename that you'd like to use. This should include a valid file extension.

 @return URL to proposed persistent store file if it exists, otherwise nil

 @since Available in v2.3 and later.
 */
+ (NSURL *) QM_fileURLForStoreNameIfExistsOnDisk:(NSString *)storeFileName;

+ (NSURL *) QM_cloudURLForUbiqutiousContainer:(NSString *)bucketName;

- (NSArray *) QM_sqliteURLs;

- (BOOL) QM_copyToURL:(NSURL *)destinationUrl error:(NSError **)error;

/**
 Removes the store files for this persistent store.

 @return YES if removing all items was successful
 
 @see +QM_removePersistentStoreFilesAtURL:

 @since Available in v2.3 and later.
 */
- (BOOL) QM_removePersistentStoreFiles;

/**
 Removes the persistent store files at the specified URL, as well as any sidecar files that are present, such as STORENAME.sqlite-shm and STORENAME.sqlite-wal

 @param url File URL pointing to an NSPersistentStore file

 @return YES if removing all items was successful

 @since Available in v2.3 and later.
 */
+ (BOOL) QM_removePersistentStoreFilesAtURL:(NSURL*)url;

@end

@interface NSPersistentStore (QMCDRecordDeprecated)

+ (NSURL *) QM_defaultURLForStoreName:(NSString *)storeFileName QM_DEPRECATED_IN_3_0_PLEASE_USE("QM_fileURLForStoreName:");
+ (NSURL *) QM_urlForStoreName:(NSString *)storeFileName QM_DEPRECATED_IN_3_0_PLEASE_USE("QM_fileURLForStoreNameIfExistsOnDisk:");

@end
