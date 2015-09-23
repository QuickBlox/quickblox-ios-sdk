//
//  NSManagedObjectContext+QMCDSaves.m
//  QMCD Record
//
//  Created by Injoit on 3/9/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSManagedObjectContext+QMCDSaves.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSError+QMCDRecordErrorHandling.h"
#import "QMCDRecordStack.h"
#import "QMCDRecordLogging.h"

@implementation NSManagedObjectContext (QMCDSaves)

- (BOOL) QM_saveOnlySelfAndWait;
{
    __block BOOL saveResult = NO;

    [self QM_saveWithOptions:MRContextSaveOptionsSaveSynchronously completion:^(BOOL success, NSError *error) {
        saveResult = success;
    }];

    return saveResult;
}

- (BOOL) QM_saveOnlySelfAndWaitWithError:(NSError **)error;
{
    __block BOOL saveResult = NO;
    __block NSError *saveError;

    [self QM_saveWithOptions:MRContextSaveOptionsSaveSynchronously completion:^(BOOL localSuccess, NSError *localError) {
        saveResult = localSuccess;
        saveError = localError;
    }];

    if (error != nil) {
        *error = saveError;
    }

    return saveResult;
}

- (void) QM_saveOnlySelfWithCompletion:(MRSaveCompletionHandler)completion;
{
    [self QM_saveWithOptions:MRContextSaveOptionsNone completion:completion];
}

- (void) QM_saveToPersistentStoreWithCompletion:(MRSaveCompletionHandler)completion;
{
    [self QM_saveWithOptions:MRContextSaveOptionsSaveParentContexts completion:completion];
}

- (BOOL) QM_saveToPersistentStoreAndWait;
{
    __block BOOL saveResult = NO;

    MRContextSaveOptions saveOptions = (MRContextSaveOptions)(MRContextSaveOptionsSaveParentContexts | MRContextSaveOptionsSaveSynchronously);
    [self QM_saveWithOptions:saveOptions completion:^(BOOL success, NSError *error) {
        saveResult = success;
    }];

    return saveResult;
}

- (BOOL) QM_saveToPersistentStoreAndWaitWithError:(NSError **)error;
{
    __block BOOL saveResult = NO;
    __block NSError *saveError;

    MRContextSaveOptions saveOptions = (MRContextSaveOptions)(MRContextSaveOptionsSaveParentContexts | MRContextSaveOptionsSaveSynchronously);

    [self QM_saveWithOptions:saveOptions completion:^(BOOL localSuccess, NSError *localError) {
        saveResult = localSuccess;
        saveError = localError;
    }];

    if (error != nil) {
        *error = saveError;
    }

    return saveResult;
}

- (void) QM_saveWithOptions:(MRContextSaveOptions)saveOptions completion:(MRSaveCompletionHandler)completion;
{
    BOOL saveParentContexts = ((saveOptions & MRContextSaveOptionsSaveParentContexts) == MRContextSaveOptionsSaveParentContexts);
    BOOL saveSynchronously = ((saveOptions & MRContextSaveOptionsSaveSynchronously) == MRContextSaveOptionsSaveSynchronously);

    __block BOOL hasChanges = NO;

    if ([self concurrencyType] == NSConfinementConcurrencyType)
    {
        hasChanges = [self hasChanges];
    }
    else
    {
        [self performBlockAndWait:^{
            hasChanges = [self hasChanges];
        }];
    }

    if (!hasChanges)
    {
        QMCDLogInfo(@"NO CHANGES IN ** %@ ** CONTEXT - NOT SAVING", [self QM_workingName]);

        if (saveParentContexts && [self parentContext])
        {
            QMCDLogVerbose(@"Proceeding to save parent context %@", [[self parentContext] QM_description]);
        }
        else
        {
            if (completion)
            {
                completion(YES, nil);
            }

            return;
        }
    }

    void (^saveBlock)(void) = ^{
        NSString *optionsSummary = @"";
        optionsSummary = [optionsSummary stringByAppendingString:saveParentContexts ? @"Save Parents,":@""];
        optionsSummary = [optionsSummary stringByAppendingString:saveSynchronously ? @"Sync Save":@""];

        QMCDLogVerbose(@"→ Saving %@ [%@]", [self QM_description], optionsSummary);

        NSError *error = nil;
        BOOL saved = NO;

        @try
        {
            saved = [self save:&error];
        }
        @catch(NSException *exception)
        {
            QMCDLogError(@"Unable to perform save: %@", (id)[exception userInfo] ? : (id)[exception reason]);
        }
        @finally
        {
            if (!saved) {
                [[error QM_coreDataDescription] QM_logToConsole];

                if (completion) {
                    completion(saved, error);
                }
            } else {
                // If we should not save the parent context, or there is not a parent context to save (root context), call the completion block
                if ((YES == saveParentContexts) && [self parentContext]) {
                    MRContextSaveOptions parentContentSaveOptions = (MRContextSaveOptions)(MRContextSaveOptionsSaveParentContexts | MRContextSaveOptionsSaveSynchronously);
                    [[self parentContext] QM_saveWithOptions:parentContentSaveOptions completion:completion];
                }
                // If we are not the default context (And therefore need to save the root context, do the completion action if one was specified
                else {
                    QMCDLogInfo(@"→ Finished saving: %@", [self QM_description]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
                    NSUInteger numberOfInsertedObjects = [[self insertedObjects] count];
                    NSUInteger numberOfUpdatedObjects = [[self updatedObjects] count];
                    NSUInteger numberOfDeletedObjects = [[self deletedObjects] count];
#pragma clang diagnostic pop
                    
                    QMCDLogVerbose(@"Objects - Inserted %tu, Updated %tu, Deleted %tu", numberOfInsertedObjects, numberOfUpdatedObjects, numberOfDeletedObjects);

                    if (completion) {
                        completion(saved, error);
                    }
                }
            }
        }
    };

    if ([self concurrencyType] == NSConfinementConcurrencyType)
    {
        saveBlock();
    }
    else if (YES == saveSynchronously)
    {
        [self performBlockAndWait:saveBlock];
    }
    else
    {
        [self performBlock:saveBlock];
    }
}

@end
