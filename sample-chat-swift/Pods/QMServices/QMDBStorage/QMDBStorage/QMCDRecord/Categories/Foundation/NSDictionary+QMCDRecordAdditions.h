//
//  NSDictionary+QMCDRecordAdditions.h
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 NSDictionary category methods to support various aspects of QMCDRecord.

 @since Available in v3.0 and later.
 */
@interface NSDictionary (QMCDRecordAdditions)

/**
 Adds the entries from another dictionary into this dictionary.

 @param dictionary Another dictionary instance

 @return Dictionary containing entries from both dictionaries.
 */
- (NSMutableDictionary *) QM_dictionaryByMergingDictionary:(NSDictionary *)dictionary;

/**
 Default SQLite store options for setting up a persistent store.

 @return Dictionary containing default options for a SQLite-based store.
 */
+ (NSDictionary *) QM_defaultSqliteStoreOptions;

/**
 Setup options for a persistent store that specify that the store should be automatically migrated if possible.

 @return Dictionary containing options for a persistent store.
 */
+ (NSDictionary *) QM_autoMigrationOptions;

/**
 Setup options for a persistent store that specify that the store should not be automatically migrated.

 @return Dictionary containing options for a persistent store.
 */
+ (NSDictionary *) QM_manualMigrationOptions;

/**
 Convenience method to read the value for the `QMCDRecordShouldDeletePersistentStoreOnModelMismatchKey` key from self and return the value as a BOOL.

 @return BOOL value for key.
 */
- (BOOL) QM_shouldDeletePersistentStoreOnModelMismatch;

@end
