//
//  ClassicSQLiteQMCDRecordStack.m
//  QMCDRecord
//
//  Created by Injoit on 10/21/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "ClassicSQLiteQMCDRecordStack.h"
#import "QMCDRecordStack+Actions.h"
#import "NSManagedObjectContext+QMCDObserving.h"
#import "QMCDRecordLogging.h"


@implementation ClassicSQLiteQMCDRecordStack

- (NSManagedObjectContext *)newConfinementContext;
{
    NSManagedObjectContext *context = [NSManagedObjectContext QM_confinementContext];
    [context setPersistentStoreCoordinator:self.coordinator];
    [context setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

    //TODO: This observation needs to be torn down by the user at this time :(
    [self.context QM_observeContextDidSave:context];
    
    return context;
}

- (void) saveWithBlock:(void (^)(NSManagedObjectContext *))block identifier:(NSString *)contextWorkingName completion:(MRSaveCompletionHandler)completion;
{
    NSParameterAssert(block);

    QMCDLogVerbose(@"Dispatching save request: %@", contextWorkingName);
    dispatch_async(QM_saveQueue(), ^{
        QMCDLogVerbose(@"%@ save starting", contextWorkingName);

        NSManagedObjectContext *localContext = [self newConfinementContext];
        NSManagedObjectContext *mainContext = [self context];

        [mainContext QM_observeContextDidSave:localContext];
        [mainContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [localContext QM_setWorkingName:contextWorkingName];

        block(localContext);

        [localContext QM_saveWithOptions:MRContextSaveOptionsSaveSynchronously completion:completion];
        [mainContext QM_stopObservingContextDidSave:localContext];
    });
}

@end
