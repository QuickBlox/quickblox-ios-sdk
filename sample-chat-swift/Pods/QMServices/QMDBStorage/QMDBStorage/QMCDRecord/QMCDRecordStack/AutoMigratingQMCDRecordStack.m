//
//  AutoMigratingQMCDRecordStack.m
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack+Private.h"
#import "AutoMigratingQMCDRecordStack.h"
#import "NSPersistentStoreCoordinator+QMCDAutoMigrations.h"

@implementation AutoMigratingQMCDRecordStack

- (NSPersistentStoreCoordinator *) createCoordinatorWithOptions:(NSDictionary *)options
{
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];

    [coordinator QM_addAutoMigratingSqliteStoreAtURL:self.storeURL];

    return coordinator;
}

@end
