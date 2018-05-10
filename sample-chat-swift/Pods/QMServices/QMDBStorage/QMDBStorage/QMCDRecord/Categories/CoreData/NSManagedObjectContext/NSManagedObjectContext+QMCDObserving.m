//
//  NSManagedObjectContext+QMCDObserving.m
//  QMCD Record
//
//  Created by Injoit on 3/9/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSManagedObjectContext+QMCDObserving.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSManagedObjectContext+QMCDSaves.h"
#import "QMCDRecordLogging.h"

NSString * const QMCDRecordDidMergeChangesFromiCloudNotification = @"kQMCDRecordDidMergeChangesFromiCloudNotification";

@implementation NSManagedObjectContext (QMCDObserving)

//MARK: - Context Observation Helpers

- (void)QM_observeContextDidSave:(NSManagedObjectContext *)otherContext
{
    if (self == otherContext) return;

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
                           selector:@selector(QM_mergeChangesFromNotification:)
                               name:NSManagedObjectContextDidSaveNotification
                             object:otherContext];
}

- (void)QM_observeContextOnMainThread:(NSManagedObjectContext *)otherContext
{
    if (self == otherContext) return;

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
                           selector:@selector(QM_mergeChangesOnMainThread:)
                               name:NSManagedObjectContextDidSaveNotification
                             object:otherContext];
}

- (void)QM_stopObservingContextDidSave:(NSManagedObjectContext *)otherContext
{
    if (self == otherContext) return;

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self
                                  name:NSManagedObjectContextDidSaveNotification
                                object:otherContext];
}


- (void)QM_observeContextDidSaveAndSaveChangesToSelf:(NSManagedObjectContext *)otherContext
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(QM_mergeChangesFromNotificationAndSaveChangesToSelfOnly:)
                               name:NSManagedObjectContextDidSaveNotification
                             object:otherContext];
}

- (void)QM_mergeChangesFromNotificationAndSaveChangesToSelfOnly:(NSNotification *)notification
{
//    QMCDLogVerbose(@"Merging changes to %@context%@", [self isEqual:[[QMCDRecordStack defaultStack] context]] ? @"*** DEFAULT *** " : @"", ([NSThread isMainThread] ? @" *** on Main Thread ***" : @"Background Thread"));

    [self mergeChangesFromContextDidSaveNotification:notification];
    [self QM_saveOnlySelfAndWait];
}

//MARK: - Context iCloud Merge Helpers

- (void)QM_mergeChangesFromiCloud:(NSNotification *)notification;
{
    void (^mergeBlock)(void) = ^{
        
        QMCDLogInfo(@"Merging changes From iCloud to %@ %@",
              [self QM_workingName],
              ([NSThread isMainThread] ? @" *** on Main Thread ***" : @""));
        
        [self mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

        [notificationCenter postNotificationName:QMCDRecordDidMergeChangesFromiCloudNotification
                                          object:self
                                        userInfo:[notification userInfo]];
    };
    
    [self performBlock:mergeBlock];
}

- (void)QM_mergeChangesFromNotification:(NSNotification *)notification;
{
    NSManagedObjectContext *fromContext = [notification object];

    if (fromContext == self) return;

    void (^mergeBlock)(void) = ^{
        QMCDLogVerbose(@"Merging changes from %@ to %@ %@",
              [fromContext QM_workingName], [self QM_workingName],
              ([NSThread isMainThread] ? @" *** on Main Thread ***" : @""));
        [self mergeChangesFromContextDidSaveNotification:notification];
    };

    [self performBlock:mergeBlock];
}

- (void)QM_mergeChangesOnMainThread:(NSNotification *)notification;
{
	if ([NSThread isMainThread])
	{
		[self QM_mergeChangesFromNotification:notification];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(QM_mergeChangesFromNotification:)
                               withObject:notification
                            waitUntilDone:YES];
	}
}

- (void)QM_observeiCloudChangesInCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(QM_mergeChangesFromiCloud:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:coordinator];
    
}

- (void)QM_stopObservingiCloudChangesInCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                object:coordinator];
}

@end
