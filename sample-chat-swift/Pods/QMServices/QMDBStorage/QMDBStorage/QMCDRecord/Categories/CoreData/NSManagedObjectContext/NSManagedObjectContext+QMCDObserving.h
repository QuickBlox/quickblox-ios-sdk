//
//  NSManagedObjectContext+QMCDObserving.h
//  QMCD Record
//
//  Created by Injoit on 3/9/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "QMCDRecordDeprecated.h"

extern NSString * const QMCDRecordDidMergeChangesFromiCloudNotification;

/**
 Category methods to aid in observing changes in other contexts.

 @since Available in v3.0 and later.
 */
@interface NSManagedObjectContext (QMCDObserving)

/**
 Merge changes from another context into self.

 @param otherContext Managed object context to observe.

 @since Available in v3.0 and later.
 */
- (void) QM_observeContextDidSave:(NSManagedObjectContext *)otherContext;

/**
 Stops merging changes from the supplied context into self.

 @param otherContext Managed object context to stop observing.

 @since Available in v3.0 and later.
 */
- (void) QM_stopObservingContextDidSave:(NSManagedObjectContext *)otherContext;

/**
 Merges changes from another context into self on the main thread.

 @param otherContext Managed object context to observe.

 @since Available in v2.0 and later.
 */
- (void) QM_observeContextOnMainThread:(NSManagedObjectContext *)otherContext;

/**
 Merges changes from another context into self, saving after each change.
 
 If self is QMCDRecord's `+QM_rootContext`, changes will be persisted to the store.

 @param otherContext Alternate context that the current context should observe
 
 @since Available in v3.0 and later.
 */
- (void) QM_observeContextDidSaveAndSaveChangesToSelf:(NSManagedObjectContext *)otherContext;

/**
 Merges changes from the supplied persistent store coordinator into self in response to changes from iCloud.

 @param coordinator Persistent store coordinator
 
 @see -QM_stopObservingiCloudChangesInCoordinator:

 @since Available in v2.0 and later.
 */
- (void) QM_observeiCloudChangesInCoordinator:(NSPersistentStoreCoordinator *)coordinator;

/**
 Stops observation and merging of changes from the supplied persistent store coordinator in response to changes from iCloud.

 @param coordinator Persistent store coordinator
 
 @see -QM_observeiCloudChangesInCoordinator:

 @since Available in v2.0 and later.
 */
- (void) QM_stopObservingiCloudChangesInCoordinator:(NSPersistentStoreCoordinator *)coordinator;

@end

@interface NSManagedObjectContext (QMCDObservingDeprecated)

- (void) QM_observeContext:(NSManagedObjectContext *)otherContext QM_DEPRECATED_IN_3_0_PLEASE_USE("QM_observeContextDidSave:");
- (void) QM_stopObservingContext:(NSManagedObjectContext *)otherContext QM_DEPRECATED_IN_3_0_PLEASE_USE("QM_stopObservingContextDidSave");

@end

