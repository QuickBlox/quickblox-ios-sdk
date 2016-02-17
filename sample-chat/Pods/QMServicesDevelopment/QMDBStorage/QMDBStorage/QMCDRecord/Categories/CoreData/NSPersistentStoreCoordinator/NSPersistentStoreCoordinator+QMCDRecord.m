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

@implementation NSPersistentStoreCoordinator (QMCDRecord)

+ (void) QM_createPathToStoreFileIfNeccessary:(NSURL *)urlForStore
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathToStore = [urlForStore URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    BOOL pathWasCreated = [fileManager createDirectoryAtPath:[pathToStore path] withIntermediateDirectories:YES attributes:nil error:&error];

    if (!pathWasCreated) 
    {
        [[error QM_coreDataDescription] QM_logToConsole];
    }
}

- (NSPersistentStore *) QM_addSqliteStoreNamed:(id)storeFileName withOptions:(__autoreleasing NSDictionary *)options;
{
    NSURL *url = [storeFileName isKindOfClass:[NSURL class]] ? storeFileName : [NSPersistentStore QM_fileURLForStoreName:storeFileName];
    return [self QM_addSqliteStoreAtURL:url withOptions:options];
}

- (NSPersistentStore *) QM_reinitializeStoreAtURL:(NSURL *)url fromError:(NSError *)error withOptions:(NSDictionary *__autoreleasing)options;
{
    NSPersistentStore *store = nil;
    BOOL isMigrationError = [error code] == NSMigrationError ||
                            [error code] == NSMigrationMissingSourceModelError ||
                            [error code] == NSPersistentStoreIncompatibleVersionHashError;
    if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError)
    {
        if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError)
        {
            // Could not open the database, so... kill it! (AND WAL bits)
            [NSPersistentStore QM_removePersistentStoreFilesAtURL:url];
            QMCDLogInfo(@"Removed incompatible model version: %@", [url lastPathComponent]);
        }

        // Try one more time to create the store
        store = [self addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:url
                                         options:options
                                           error:&error];
        if (store)
        {
            // If we successfully added a store, remove the error that was initially created
            error = nil;
        }
    }

    return store;
}

- (NSPersistentStore *) QM_addSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *__autoreleasing)options
{
    [[self class] QM_createPathToStoreFileIfNeccessary:url];

    QMCDLogVerbose(@"Adding store at [%@] to NSPSC with options [%@]", url, options);
    @try {
        
        NSError *error = nil;
        NSPersistentStore *store = [self addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:url
                                                            options:options
                                                              error:&error];
        
        if ([options QM_shouldDeletePersistentStoreOnModelMismatch] && store == nil && error != nil)
        {
            store = [self QM_reinitializeStoreAtURL:url fromError:error withOptions:options];
        }
        if (error)
        {
            QMCDLogError(@"Unable to setup store at URL: %@", url);
            [[error QM_coreDataDescription] QM_logToConsole];
        }
        return store;
    }
    @catch (NSException *exception)
    {
        [[exception description] QM_logToConsole];
    }
    return nil;
}

+ (NSPersistentStoreCoordinator *) QM_newPersistentStoreCoordinator
{
	NSPersistentStoreCoordinator *coordinator = [self QM_coordinatorWithSqliteStoreNamed:[QMCDRecord defaultStoreName]];

    return coordinator;
}

#pragma mark - Persistent Store Initializers

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore
{
    NSManagedObjectModel *defaultStackModel = [[QMCDRecordStack defaultStack] model];

    return [self QM_coordinatorWithPersistentStore:persistentStore andModel:defaultStackModel];;
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore andModel:(NSManagedObjectModel *)model
{
    return [self QM_coordinatorWithPersistentStore:persistentStore andModel:model withOptions:nil];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options
{
    NSPersistentStoreCoordinator *psc = [[self alloc] initWithManagedObjectModel:model];

    [psc QM_addSqliteStoreNamed:[persistentStore URL] withOptions:options];

    return psc;
}

#pragma mark - Store Name Initializers

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreNamed:(NSString *)storeFileName
{
	return [self QM_coordinatorWithSqliteStoreNamed:storeFileName withOptions:nil];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreNamed:(NSString *)storeFileName withOptions:(NSDictionary *)options
{
    NSManagedObjectModel *defaultStackModel = [[QMCDRecordStack defaultStack] model];

    return [self QM_coordinatorWithSqliteStoreNamed:storeFileName andModel:defaultStackModel withOptions:options];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreNamed:(NSString *)storeFileName andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options
{
    NSPersistentStoreCoordinator *psc = [[self alloc] initWithManagedObjectModel:model];

    [psc QM_addSqliteStoreNamed:storeFileName withOptions:options];

    return psc;
}

#pragma mark - URL Initializers

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreAtURL:(NSURL *)url
{
    NSManagedObjectModel *defaultStackModel = [[QMCDRecordStack defaultStack] model];

    return [self QM_coordinatorWithSqliteStoreAtURL:url andModel:defaultStackModel];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreAtURL:(NSURL *)url andModel:(NSManagedObjectModel *)model
{
    return [self QM_coordinatorWithSqliteStoreAtURL:url andModel:model withOptions:nil];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreAtURL:(NSURL *)url andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options
{
    NSPersistentStoreCoordinator *psc = [[self alloc] initWithManagedObjectModel:model];

    [psc QM_addSqliteStoreAtURL:url withOptions:options];

    return psc;
}

@end


