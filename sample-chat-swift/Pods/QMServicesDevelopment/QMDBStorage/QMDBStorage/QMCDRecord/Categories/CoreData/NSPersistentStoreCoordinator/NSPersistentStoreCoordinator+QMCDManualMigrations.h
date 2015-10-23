//
//  NSPersistentStoreCoordinator+QMCDManualMigrations.h
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (QMCDManualMigrations)

- (NSPersistentStore *) QM_addManuallyMigratingSqliteStoreAtURL:(NSURL *)url;
- (NSPersistentStore *) QM_addManuallyMigratingSqliteStoreNamed:(NSString *)storeFileName;

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithManuallyMigratingSqliteStoreNamed:(NSString *)storeFileName;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithManuallyMigratingSqliteStoreAtURL:(NSURL *)url;

@end
