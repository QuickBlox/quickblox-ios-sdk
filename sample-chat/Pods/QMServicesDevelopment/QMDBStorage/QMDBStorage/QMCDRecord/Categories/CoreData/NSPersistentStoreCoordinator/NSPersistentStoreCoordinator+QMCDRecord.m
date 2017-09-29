//
//  NSPersistentStoreCoordinator+QMCDRecord.m
//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSDictionary+QMCDRecordAdditions.h"
#import "QMCDRecord.h"
#import "QMCDRecordLogging.h"

NSString * const QMCDRecordShouldDeletePersistentStoreOnModelMismatchKey = @"QMCDRecordShouldDeletePersistentStoreOnModelMistachKey";

NSString * const QMCDRecordShouldMigrateKey = @"QMCDRecordShouldMigrateKey";
NSString * const QMCDRecordShouldDeleteOldDBKey = @"QMCDRecordShouldDeleteOldDBKey";

NSString * const QMCDRecordTargetURLKey = @"QMCDRecordTargetURLKey";
NSString * const QMCDRecordSourceURLKey = @"QMCDRecordSourceURLKey";
NSString * const QMCDRecordGroupURLKey = @"QMCDRecordGroupURLKey";

@implementation NSPersistentStoreCoordinator (QMCDRecord)

+ (void)QM_createPathToStoreFileIfNeccessary:(NSURL *)urlForStore {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathToStore = [urlForStore URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    BOOL pathWasCreated = [fileManager createDirectoryAtPath:[pathToStore path]
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error];
    if (!pathWasCreated) {
        [[error QM_coreDataDescription] QM_logToConsole];
    }
}

- (NSPersistentStore *)QM_addSqliteStoreNamed:(id)storeFileName
                                  withOptions:(__autoreleasing NSDictionary *)options {
    
    NSURL *url = [storeFileName isKindOfClass:[NSURL class]] ?
    storeFileName : [NSPersistentStore QM_fileURLForStoreName:storeFileName];
    
    return [self QM_addSqliteStoreAtURL:url
                            withOptions:options];
}

- (NSPersistentStore *)QM_reinitializeStoreAtURL:(NSURL *)url
                                       fromError:(NSError *)error
                                     withOptions:(NSDictionary *__autoreleasing)options {
    NSPersistentStore *store = nil;
    BOOL isMigrationError = [error code] == NSMigrationError ||
    [error code] == NSMigrationMissingSourceModelError ||
    [error code] == NSPersistentStoreIncompatibleVersionHashError;
    
    if ([error.domain isEqualToString:NSCocoaErrorDomain] && isMigrationError) {
        
        if ([error.domain isEqualToString:NSCocoaErrorDomain] && isMigrationError) {
            // Could not open the database, so... kill it! (AND WAL bits)
            [NSPersistentStore QM_removePersistentStoreFilesAtURL:url];
            QMCDLogInfo(@"Removed incompatible model version: %@",
                        url.lastPathComponent);
        }
        // Try one more time to create the store
        store = [self addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:url
                                         options:options
                                           error:&error];
        if (store) {
            // If we successfully added a store, remove the error that was initially created
            error = nil;
        }
    }
    
    return store;
}

- (NSPersistentStore *)QM_addSqliteStoreAtURL:(NSURL *)url
                                  withOptions:(NSDictionary *__autoreleasing)options {
    
    [[self class] QM_createPathToStoreFileIfNeccessary:url];
    
    QMCDLogVerbose(@"Adding store at [%@] to NSPSC with options [%@]",
                   url, options);
    @try {
        
        NSError *error = nil;
        BOOL needMigrate =
        [options[QMCDRecordShouldMigrateKey] boolValue];
        
        BOOL needDeleteOldStore =
        [options[QMCDRecordShouldDeleteOldDBKey] boolValue];
        
        NSPersistentStore *store =
        [self addPersistentStoreWithType:NSSQLiteStoreType
                           configuration:nil
                                     URL:url
                                 options:[NSDictionary QM_autoMigrationOptions]
                                   error:&error];
        
        if ([options QM_shouldDeletePersistentStoreOnModelMismatch] &&
            store == nil && error != nil) {
            
            store = [self QM_reinitializeStoreAtURL:url
                                          fromError:error
                                        withOptions:options];
        }
        
        if (error) {
            QMCDLogError(@"Unable to setup store at URL: %@", url);
            [[error QM_coreDataDescription] QM_logToConsole];
        }
        
        if (needMigrate) {
            
            NSError *error = nil;
            NSURL *migrationURL = options[QMCDRecordGroupURLKey];
           store = [self migratePersistentStore:store
                                   toURL:migrationURL
                                 options:[NSDictionary QM_autoMigrationOptions]
                                withType:NSSQLiteStoreType
                                   error:&error];
            if (error) {
                QMCDLogError(@"Unable to migrate store at URL: %@", url);
                [[error QM_coreDataDescription] QM_logToConsole];
            }
            
        }
        
        if (needDeleteOldStore) {
            [NSPersistentStore QM_removePersistentStoreFilesAtURL:
             options[QMCDRecordSourceURLKey]];
        }
        
        return store;
    }
    @catch (NSException *exception) {
        
        [[exception description] QM_logToConsole];
    }
    
    return nil;
}

@end

