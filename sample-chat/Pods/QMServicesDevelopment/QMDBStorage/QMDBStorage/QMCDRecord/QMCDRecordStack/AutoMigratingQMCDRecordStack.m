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
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "QMCDRecordLogging.h"

@implementation AutoMigratingQMCDRecordStack

- (NSPersistentStoreCoordinator *) createCoordinatorWithOptions:(NSDictionary *)options
{
    QMCDLogVerbose(@"Loading Store at URL: %@", self.storeURL);
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    
    NSMutableDictionary *storeOptions = [[self defaultStoreOptions] mutableCopy];
    [storeOptions addEntriesFromDictionary:self.storeOptions];
    
    [coordinator QM_addAutoMigratingSqliteStoreAtURL:self.storeURL withOptions:storeOptions];

    return coordinator;
}

@end
