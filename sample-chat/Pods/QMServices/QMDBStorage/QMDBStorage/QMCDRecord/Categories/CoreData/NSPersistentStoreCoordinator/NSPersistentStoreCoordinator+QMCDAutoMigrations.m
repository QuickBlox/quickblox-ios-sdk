//
//  NSPersistentStoreCoordinator+QMCDAutoMigrations.m
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSPersistentStoreCoordinator+QMCDAutoMigrations.h"
#import "NSDictionary+QMCDRecordAdditions.h"
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "QMCDRecordStack.h"

@implementation NSPersistentStoreCoordinator (QMCDAutoMigrations)

- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreNamed:(NSString *)storeFileName;
{
    NSDictionary *options = [NSDictionary QM_autoMigrationOptions];
    return [self QM_addAutoMigratingSqliteStoreNamed:storeFileName withOptions:options];
}

- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreNamed:(NSString *)storeFileName withOptions:(NSDictionary *)options;
{
    return [self QM_addSqliteStoreNamed:storeFileName withOptions:options];
}

- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreAtURL:(NSURL *)url;
{
    NSDictionary *options = [NSDictionary QM_autoMigrationOptions];
    return [self QM_addAutoMigratingSqliteStoreAtURL:url withOptions:options];
}

- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *)options;
{
    return [self QM_addSqliteStoreAtURL:url withOptions:options];
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName;
{
    NSManagedObjectModel *model = [[QMCDRecordStack defaultStack] model];
    NSPersistentStoreCoordinator *coordinator = [[self alloc] initWithManagedObjectModel:model];

    [coordinator QM_addAutoMigratingSqliteStoreNamed:storeFileName];

    //HACK: lame solution to fix automigration error "Migration failed after first pass"
    if ([[coordinator persistentStores] count] == 0)
    {
        [coordinator performSelector:@selector(QM_addAutoMigratingSqliteStoreNamed:) withObject:storeFileName afterDelay:0.5];
    }

    return coordinator;
}

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithAutoMigratingSqliteStoreAtURL:(NSURL *)url;
{
    NSManagedObjectModel *model = [[QMCDRecordStack defaultStack] model];
    NSPersistentStoreCoordinator *coordinator = [[self alloc] initWithManagedObjectModel:model];

    [coordinator QM_addAutoMigratingSqliteStoreAtURL:url];

    //HACK: lame solution to fix automigration error "Migration failed after first pass"
    if ([[coordinator persistentStores] count] == 0)
    {
        [coordinator performSelector:@selector(QM_addAutoMigratingSqliteStoreAtURL:) withObject:url afterDelay:0.5];
    }

    return coordinator;
}

@end
