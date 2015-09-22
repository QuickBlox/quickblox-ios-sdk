//
//  DualContextDualCoordinatorQMCDRecordStack.m
//  QMCDRecord
//
//  Created by Injoit on 10/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "ClassicWithBackgroundCoordinatorSQLiteQMCDRecordStack.h"
#import "NSPersistentStoreCoordinator+QMCDRecord.h"
#import "NSDictionary+QMCDRecordAdditions.h"
#import "NSManagedObjectContext+QMCDObserving.h"
#import "NSManagedObjectContext+QMCDRecord.h"

#import "QMCDRecordLogging.h"


@interface ClassicWithBackgroundCoordinatorSQLiteQMCDRecordStack ()

@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *backgroundCoordinator;

@end


@implementation ClassicWithBackgroundCoordinatorSQLiteQMCDRecordStack

- (NSString *)description;
{
    NSMutableString *description = [[super description] mutableCopy];

    [description appendFormat:@"Background Coordinator:     %@\n", self.backgroundCoordinator];
    
    return [NSString stringWithString:description];
}

- (void)reset;
{
    self.backgroundCoordinator = nil;
    [super reset];
}

- (NSManagedObjectContext *) newConfinementContext;
{
    //TODO: need to setup backgroundContext -> context merges via NSNC, and unsubscribe automatically
    NSManagedObjectContext *backgroundContext = [NSManagedObjectContext QM_confinementContext];
    [backgroundContext setPersistentStoreCoordinator:self.backgroundCoordinator];
    return backgroundContext;
}

- (NSPersistentStoreCoordinator *)backgroundCoordinator;
{
    if (_backgroundCoordinator == nil)
    {
        _backgroundCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
        [_backgroundCoordinator QM_addSqliteStoreAtURL:[self storeURL] withOptions:[self defaultStoreOptions]];
    }
    return _backgroundCoordinator;
}


@end
