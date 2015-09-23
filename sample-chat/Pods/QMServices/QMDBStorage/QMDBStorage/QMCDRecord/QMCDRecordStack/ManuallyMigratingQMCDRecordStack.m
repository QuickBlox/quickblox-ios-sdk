//
//  ManuallyMigratingQMCDRecordStack.m
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack+Private.h"
#import "ManuallyMigratingQMCDRecordStack.h"
#import "NSPersistentStoreCoordinator+QMCDManualMigrations.h"

@implementation ManuallyMigratingQMCDRecordStack

- (NSPersistentStoreCoordinator *) createCoordinator;
{
    NSPersistentStoreCoordinator
    *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    [coordinator QM_addManuallyMigratingSqliteStoreAtURL:self.storeURL];

    return coordinator;
}

@end
