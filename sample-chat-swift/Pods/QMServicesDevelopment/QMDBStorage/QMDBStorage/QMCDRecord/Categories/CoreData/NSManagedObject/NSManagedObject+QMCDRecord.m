
//  Created by Injoit on 11/15/09.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "QMCDRecordStack.h"
#import "QMCDRecordLogging.h"

@implementation NSManagedObject (QMCDRecord)

#pragma mark - Entity Information

+ (NSString *) QM_entityName;
{
    NSString *entityName;

    if ([self respondsToSelector:@selector(entityName)])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
        entityName = [self performSelector:@selector(entityName)];
#pragma clang diagnostic pop
    }

    if ([entityName length] == 0)
    {
        entityName = NSStringFromClass(self);
    }

    return entityName;
}

+ (NSEntityDescription *) QM_entityDescription
{
	return [self QM_entityDescriptionInContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSEntityDescription *) QM_entityDescriptionInContext:(NSManagedObjectContext *)context
{
    NSString *entityName = [self QM_entityName];
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
}

+ (NSArray *) QM_propertiesNamed:(NSArray *)properties
{
    return [self QM_propertiesNamed:properties inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSArray *) QM_propertiesNamed:(NSArray *)properties inContext:(NSManagedObjectContext *)context
{
	NSEntityDescription *description = [self QM_entityDescriptionInContext:context];
	NSMutableArray *propertiesWanted = [NSMutableArray array];

	if (properties)
	{
		NSDictionary *propDict = [description propertiesByName];

		for (NSString *propertyName in properties)
		{
			NSPropertyDescription *property = [propDict objectForKey:propertyName];
			if (property)
			{
				[propertiesWanted addObject:property];
			}
			else
			{
				QMCDLogWarn(@"Property '%@' not found in %tu properties for %@", propertyName, [propDict count], NSStringFromClass(self));
			}
		}
	}
	return propertiesWanted;
}

#pragma mark - Fetch Requests

+ (NSArray *) QM_executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    void (^requestBlock)(void) = ^{

        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];

        if (results == nil)
        {
            [[error QM_coreDataDescription] QM_logToConsole];
        }
    };

    if ([context concurrencyType] == NSConfinementConcurrencyType)
    {
        requestBlock();
    }
    else
    {
        [context performBlockAndWait:requestBlock];
    }
	return results;
}

+ (NSArray *) QM_executeFetchRequest:(NSFetchRequest *)request
{
	return [self QM_executeFetchRequest:request inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
	[request setFetchLimit:1];

	NSArray *results = [self QM_executeFetchRequest:request inContext:context];
	if ([results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

+ (id) QM_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
{
	return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:[[QMCDRecordStack defaultStack] context]];
}

#pragma mark - Creating Entities

+ (instancetype) QM_createEntity
{
	return [self QM_createEntityInContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_createEntityInContext:(NSManagedObjectContext *)context
{
    return [self QM_createEntityWithDescription:nil inContext:context];
}

+ (instancetype) QM_createEntityWithDescription:(NSEntityDescription *)entityDescription inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = entityDescription;

    if (!entity)
    {
        entity = [self QM_entityDescriptionInContext:context];
    }

//    [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    NSManagedObject *managedObject = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:context];

    if ([managedObject respondsToSelector:@selector(QM_awakeFromCreation)])
    {
        [managedObject QM_awakeFromCreation];
    }

    return managedObject;
}

- (BOOL) QM_isTemporaryObject;
{
    return [[self objectID] isTemporaryID];
}

#pragma mark - Deleting Entities

- (BOOL) QM_isEntityDeleted
{
    return [self isDeleted] || [self managedObjectContext] == nil;
}

- (BOOL) QM_deleteEntity
{
	return [self QM_deleteEntityInContext:[self managedObjectContext]];
}

- (BOOL) QM_deleteEntityInContext:(NSManagedObjectContext *)context
{
    NSError *retrieveExistingObjectError;
    NSManagedObject *objectInContext = [context existingObjectWithID:[self objectID] error:&retrieveExistingObjectError];

    [[retrieveExistingObjectError QM_coreDataDescription] QM_logToConsole];

    [context deleteObject:objectInContext];

    return [objectInContext QM_isEntityDeleted];
}

+ (BOOL) QM_deleteAllMatchingPredicate:(NSPredicate *)predicate
{
    return [self QM_deleteAllMatchingPredicate:predicate inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (BOOL) QM_deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self QM_requestAllWithPredicate:predicate];
    [request setReturnsObjectsAsFaults:YES];
	[request setIncludesPropertyValues:NO];

	NSArray *objectsToTruncate = [self QM_executeFetchRequest:request inContext:context];

	for (NSManagedObject *objectToTruncate in objectsToTruncate)
    {
		[objectToTruncate QM_deleteEntityInContext:context];
	}

	return YES;
}

+ (BOOL) QM_truncateAll
{
    [self QM_truncateAllInContext:[[QMCDRecordStack defaultStack] context]];
    return YES;
}

+ (BOOL) QM_truncateAllInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self QM_requestAll];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];

    NSArray *objectsToDelete = [self QM_executeFetchRequest:request inContext:context];
    for (NSManagedObject *objectToDelete in objectsToDelete)
    {
        [objectToDelete QM_deleteEntityInContext:context];
    }
    return YES;
}

#pragma mark - Sorting Entities

+ (NSArray *) QM_ascendingSortDescriptors:(NSArray *)attributesToSortBy
{
	return [self QM_sortAscending:YES attributes:attributesToSortBy];
}

+ (NSArray *) QM_descendingSortDescriptors:(NSArray *)attributesToSortBy
{
	return [self QM_sortAscending:NO attributes:attributesToSortBy];
}

+ (NSArray *) QM_sortAscending:(BOOL)ascending attributes:(NSArray *)attributesToSortBy
{
	NSMutableArray *attributes = [NSMutableArray array];

    for (NSString *attributeName in attributesToSortBy)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attributeName ascending:ascending];
        [attributes addObject:sortDescriptor];
    }

	return attributes;
}

#pragma mark - Working Across Contexts

- (void) QM_refresh;
{
    [[self managedObjectContext] refreshObject:self mergeChanges:YES];
}

- (void) QM_obtainPermanentObjectID;
{
    if ([[self objectID] isTemporaryID])
    {
        NSError *error = nil;

        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:[NSArray arrayWithObject:self] error:&error];
        if (!success)
        {
            [[error QM_coreDataDescription] QM_logToConsole];
        }
    }
}

- (instancetype) QM_inContext:(NSManagedObjectContext *)otherContext;
{
    NSManagedObject *inContext = nil;
    NSManagedObjectID *objectID = [self objectID];
    if (otherContext == [self managedObjectContext])
    {
        inContext = self;
    }
    else if ([objectID isTemporaryID])
    {
        NSString *reason = [NSString stringWithFormat:@"Cannot load a temporary object '%@' [%@] across managed object contexts. Please obtain a permanent ID for this object first.", self, [self objectID]];
        @throw [NSException exceptionWithName:NSObjectInaccessibleException reason:reason userInfo:@{@"object" : self}];
    }
    else
    {
        inContext = [otherContext objectRegisteredForID:objectID];  //see if its already there
        if (inContext == nil)
        {
            NSError *error = nil;
            inContext = [otherContext existingObjectWithID:objectID error:&error];

            if (inContext == nil)
            {
                QMCDLogWarn(@"Did not find object %@ in context '%@': %@", self, [otherContext QM_description], error);
            }
        }
    }
    return inContext;
}

- (instancetype) QM_inContextIfTemporaryObject:(NSManagedObjectContext *)otherContext
{
    NSManagedObjectID *objectID = [self objectID];
    if ([objectID isTemporaryID])
    {
        return self;
    }
    else
    {
        return [self QM_inContext:otherContext];
    }
}

#pragma mark - Validation

- (BOOL) QM_isValidForInsert;
{
    NSError *error = nil;
    BOOL isValid = [self validateForInsert:&error];
    if (!isValid)
    {
        [[error QM_coreDataDescription] QM_logToConsole];
    }
    
    return isValid;
}

- (BOOL) QM_isValidForUpdate;
{
    NSError *error = nil;
    BOOL isValid = [self validateForUpdate:&error];
    if (!isValid)
    {
        [[error QM_coreDataDescription] QM_logToConsole];
    }

    return isValid;
}

@end

#pragma mark - Deprecated Methods
@implementation NSManagedObject (QMCDRecordDeprecated)

+ (instancetype) QM_createInContext:(NSManagedObjectContext *)context
{
    return [self QM_createEntityInContext:context];
}

- (BOOL) QM_deleteInContext:(NSManagedObjectContext *)context
{
    return [self QM_deleteEntityInContext:context];
}

- (instancetype) QM_inContextIfTempObject:(NSManagedObjectContext *)otherContext;
{
    return [self QM_inContextIfTemporaryObject:otherContext];
}

@end

