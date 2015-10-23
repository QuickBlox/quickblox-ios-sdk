//
//  NSError+QMCDRecordErrorHandling.m
//  Sidekick
//
//  Created by Injoit on 5/7/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSError+QMCDRecordErrorHandling.h"
#import "QMCDRecordLogging.h"

NSDictionary *QM_validationErrorCodeLookup(void);

NSDictionary *QM_errorCodeSummaryLookup(void);
NSDictionary *QM_objectGraphErrorCodeLooup(void);
NSDictionary *QM_persistentStoreErrorCodeLookup(void);
NSDictionary *QM_migrationErrorCodeLookup(void);

NSString *QM_errorSummaryFromErrorCode(NSInteger errorCode)
{
    static NSDictionary *errorCodes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorCodes = QM_errorCodeSummaryLookup();
    });

    NSString *summary = [errorCodes objectForKey:@(errorCode)];
    if (summary == nil)
    {
        summary = [NSString stringWithFormat:@"Unknown Core Data Error Code (%zd)", errorCode];
    }
    return summary;
}

@implementation NSString (QMCDRecordLogging)

- (void) QM_logToConsole;
{
    QMCDLogVerbose(@"*** %@ ***", self);
}

@end


@implementation NSError (QMCDRecordErrorHandling)

- (NSArray *) QM_errorCollection;
{
    return [self code] == NSValidationMultipleErrorsError ? [[self userInfo] valueForKey:NSDetailedErrorsKey] : @[self];
}

- (NSDictionary *) QM_errorCollectionGroupedByObject;
{
    NSMutableDictionary *collatedObjects = [NSMutableDictionary dictionary];
    [[self QM_errorCollection] enumerateObjectsUsingBlock:^(NSError *error, NSUInteger idx, BOOL *stop) {
        NSManagedObject *errorObject = [error QM_validationErrorObject];

        NSMutableArray *errorList = [collatedObjects objectForKey:[errorObject objectID]];
        if (errorList == nil)
        {
            errorList = [NSMutableArray array];
            [collatedObjects setObject:errorList forKey:[errorObject objectID]];
        }

        [errorList addObject:error];
        
    }];
    return [NSDictionary dictionaryWithDictionary:collatedObjects];
}

- (NSString *) QM_summaryDescription;
{
    NSInteger errorCode = [self code];
    if (QM_errorCodeIsValidationErrorCode(errorCode))
    {
        return [NSString stringWithFormat:@"- [Validation] %@, Invalid Property: [%@], ManagedObject: [%@]",
                QM_errorSummaryFromErrorCode(errorCode),
                [self QM_validationError],
                [self QM_validationErrorObject]];
    }
    else if (errorCode == NSManagedObjectMergeError)
    {
        return [[self userInfo] valueForKey:@"conflictList"];
    }
    return [NSString stringWithFormat:@"(%zd) %@ [%@]", errorCode, QM_errorSummaryFromErrorCode(errorCode), [self QM_validationErrorObject] ?: [[self userInfo] valueForKey:@"reason"]];
}

- (NSString *) QM_coreDataDescription;
{
    NSMutableString *descriptionBuffer = [NSMutableString string];
    
    if ([self code] == NSValidationMultipleErrorsError)
    {
        [descriptionBuffer appendString:@"Multiple Validation Errors --\n"];
        NSDictionary *groupedErrors = [self QM_errorCollectionGroupedByObject];
        [[groupedErrors allKeys] enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, NSUInteger idx, BOOL *stop) {
            
            [descriptionBuffer appendFormat:@" Object: %@ -", managedObject];
            NSArray *errors = [groupedErrors objectForKey:managedObject];
            [errors enumerateObjectsUsingBlock:^(NSError *error, NSUInteger inneridx, BOOL *innerstop) {
                [descriptionBuffer appendFormat:@" %@ [%@],",[error QM_validationError], QM_errorSummaryFromErrorCode([error code])];
            }];
            [descriptionBuffer deleteCharactersInRange:NSMakeRange([descriptionBuffer length] - 1, 1)];
            [descriptionBuffer appendString:@"\n"];
        }];
    }
    else
    {
        [[self QM_errorCollection] enumerateObjectsUsingBlock:^(NSError *obj, NSUInteger idx, BOOL *stop) {
            [descriptionBuffer appendFormat:@" %@\n", [obj QM_summaryDescription]];
        }];
    }
    
    return [NSString stringWithString:descriptionBuffer];
}

- (id) QM_validationError;
{
    return [[self userInfo] valueForKey:NSValidationKeyErrorKey];
}

- (NSManagedObject *) QM_validationErrorObject;
{
    return [[self userInfo] objectForKey:NSValidationObjectErrorKey];
}

@end


/*********************
 Returns a lookup table of error codes to human readable strings as specified in the Core Data Constants Reference:
 https://developer.apple.com/library/mac/documentation/Cocoa/Reference/CoreDataFramework/Miscellaneous/CoreData_Constants/Reference/reference.html
 */
NSDictionary *QM_validationErrorCodeLookup(void)
{
    static NSDictionary *validationErrorMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        validationErrorMap =
            @{
              @(NSValidationMultipleErrorsError): @"General Validation Error",
              @(NSValidationMissingMandatoryPropertyError): @"Missing Mandiatory Property",
              @(NSValidationRelationshipLacksMinimumCountError): @"Relationship Lacks Minimum Count",
              @(NSValidationRelationshipExceedsMaximumCountError): @"Relationship Exceeds Maximum Count",
              @(NSValidationRelationshipDeniedDeleteError): @"Relationship Denied Delete",
              @(NSValidationNumberTooLargeError): @"Number too Large",
              @(NSValidationNumberTooSmallError): @"Number too Small",
              @(NSValidationDateTooLateError): @"Date too Late",
              @(NSValidationDateTooSoonError): @"Date too Soon",
              @(NSValidationInvalidDateError): @"Invalid Date",
              @(NSValidationStringTooLongError): @"String too Long",
              @(NSValidationStringTooShortError): @"String too Short",
              @(NSValidationStringPatternMatchingError): @"String Pattering Matching Error"
          };
    });
    return validationErrorMap;
}
BOOL QM_errorCodeIsValidationErrorCode(NSInteger errorCode)
{
    NSDictionary *validationLookup = QM_validationErrorCodeLookup();
    return [[validationLookup allKeys] containsObject:@(errorCode)];
}

NSDictionary *QM_migrationErrorCodeLookup(void)
{
    static NSDictionary *migrationErrorDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        migrationErrorDictionary =

    @{
      @(NSMigrationError): @"General Migration Error",
      @(NSMigrationCancelledError): @"Migration Cancelled",
      @(NSMigrationMissingSourceModelError): @"Migration Missing Source Model",
      @(NSMigrationMissingMappingModelError): @"Migration Missing Mapping Model",
      @(NSMigrationManagerSourceStoreError): @"Migration Manager Source Store Problem",
      @(NSMigrationManagerDestinationStoreError): @"Migration Manager Destination Store Problem",
      @(NSEntityMigrationPolicyError): @"Entity Migration Policy Failure",
      @(NSInferredMappingModelError): @"Error Inferring Mapping Model",
      @(NSExternalRecordImportError): @"Error Importing External Records"
      };
            });
    return migrationErrorDictionary;
}
BOOL QM_errorCodeIsMigrationErrorCode(NSInteger errorCode)
{
    NSDictionary *lookup = QM_migrationErrorCodeLookup();
    return [[lookup allKeys] containsObject:@(errorCode)];
}

NSDictionary *QM_persistentStoreErrorCodeLookup(void)
{
    static NSDictionary *persistentStoreErrorDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        persistentStoreErrorDictionary =
    @{
      @(NSPersistentStoreInvalidTypeError): @"Invalid type specified for persistent store",
      @(NSPersistentStoreTypeMismatchError): @"Store does not match specified type",
      @(NSPersistentStoreIncompatibleSchemaError): @"Unable to save. Error in persistent store (missing table?).",
      @(NSPersistentStoreSaveError): @"Unable to save. Error in persistent store (permission error?).",
      @(NSPersistentStoreIncompleteSaveError): @"One or more stores failed to save",
      @(NSPersistentStoreSaveConflictsError): @"Unable to resolve merge conflicts during save",
      @(NSPersistentStoreOperationError): @"Error in persistent store. Store level operation failed",
      @(NSPersistentStoreOpenError): @"Unable to open persistent store",
      @(NSPersistentStoreTimeoutError): @"Timeout expired connecting to persistent store",
      @(NSPersistentStoreUnsupportedRequestTypeError): @"Did not understand request type",
      @(NSPersistentStoreIncompatibleVersionHashError): @"Store version info does not match managed object model version info"
      };
    });
    return persistentStoreErrorDictionary;
}
BOOL QM_errorCodeIsPersistentStoreErrorCode(NSInteger errorCode)
{
    NSDictionary *lookup = QM_persistentStoreErrorCodeLookup();
    return [[lookup allKeys] containsObject:@(errorCode)];
}

NSDictionary *QM_objectGraphErrorCodeLooup(void)
{
    static NSDictionary *objectGraphErrorCodeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        objectGraphErrorCodeMap =
    @{
      @(NSManagedObjectContextLockingError): @"Unable to aquire lock in NSManagedObjectContext instance",
      @(NSPersistentStoreCoordinatorLockingError): @"Unable to aquire lock in NSPersistentStoreCoordinator instance",
      @(NSManagedObjectReferentialIntegrityError): @"Attempted to fire fault pointing to non-existant object in store",
      @(NSManagedObjectExternalRelationshipError): @"Object being saved has relationship containing object from a different store",
      @(NSManagedObjectMergeError): @"Merge policy failed"
      };
    });
    return objectGraphErrorCodeMap;
}
BOOL QM_errorCodeIsObjectGraphErrorCode(NSInteger errorCode)
{
    NSDictionary *lookup = QM_objectGraphErrorCodeLooup();
    return [[lookup allKeys] containsObject:@(errorCode)];
}

NSDictionary *QM_errorCodeSummaryLookup(void)
{
    NSMutableDictionary *combinedErrorCodes = [NSMutableDictionary dictionary];
    [combinedErrorCodes addEntriesFromDictionary:QM_validationErrorCodeLookup()];
    [combinedErrorCodes addEntriesFromDictionary:QM_migrationErrorCodeLookup()];
    [combinedErrorCodes addEntriesFromDictionary:QM_persistentStoreErrorCodeLookup()];
    [combinedErrorCodes addEntriesFromDictionary:QM_objectGraphErrorCodeLooup()];

    return [NSDictionary dictionaryWithDictionary:combinedErrorCodes];
}
