//
//  NSPersistentStoreCoordinator+QMCDAutoMigrations.h
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (QMCDAutoMigrations)

- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreNamed:(NSString *)storeFileName;
- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreNamed:(NSString *)storeFileName withOptions:(NSDictionary *)options;

- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreAtURL:(NSURL *)url;
- (NSPersistentStore *) QM_addAutoMigratingSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *)options;

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithAutoMigratingSqliteStoreAtURL:(NSURL *)url;

@end
