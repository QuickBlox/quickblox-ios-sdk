
//  Created by Injoit on 11/15/09.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "QMCDRecordStack.h"
#import "QMCDRecordLogging.h"

@implementation NSManagedObject (QMCDRecord)

//MARK: - Entity Information

+ (NSString *)QM_entityName {
    
    NSString *entityName;
    
    if ([self respondsToSelector:@selector(entityName)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
        entityName = [self performSelector:@selector(entityName)];
#pragma clang diagnostic pop
    }
    
    if ([entityName length] == 0) {
        entityName = NSStringFromClass(self);
    }
    
    return entityName;
}

+ (NSEntityDescription *)QM_entityDescriptionInContext:(NSManagedObjectContext *)context {
    
    NSString *entityName = [self QM_entityName];
    
    return [NSEntityDescription entityForName:entityName
                       inManagedObjectContext:context];
}

+ (NSArray *)QM_propertiesNamed:(NSArray *)properties
                      inContext:(NSManagedObjectContext *)context {
    
    NSEntityDescription *description = [self QM_entityDescriptionInContext:context];
    NSMutableArray *propertiesWanted = [NSMutableArray array];
    
    if (properties) {
        
        NSDictionary *propDict = [description propertiesByName];
        
        for (NSString *propertyName in properties) {
            
            NSPropertyDescription *property =
            [propDict objectForKey:propertyName];
            if (property) {
                [propertiesWanted addObject:property];
            }
            else {
                
                QMCDLogWarn(@"Property '%@' not found in %tu properties for %@",
                            propertyName, [propDict count], NSStringFromClass(self));
            }
        }
    }
    
    return propertiesWanted;
}

//MARK: - Fetch Requests

+ (NSArray *)QM_executeFetchRequest:(NSFetchRequest *)request
                          inContext:(NSManagedObjectContext *)context {
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        results = [context executeFetchRequest:request
                                         error:&error];
        if (results == nil) {
            
            [[error QM_coreDataDescription] QM_logToConsole];
        }
    }];
    
    return results;
}

+ (id)QM_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
                                       inContext:(NSManagedObjectContext *)context {
    [request setFetchLimit:1];
    
    NSArray *results = [self QM_executeFetchRequest:request
                                          inContext:context];
    if ([results count] == 0) {
        return nil;
    }
    
    return [results objectAtIndex:0];
}

//MARK: - Creating Entities

+ (instancetype)QM_createEntityInContext:(NSManagedObjectContext *)context {
    
    return [self QM_createEntityWithDescription:nil
                                      inContext:context];
}

+ (instancetype)QM_createEntityWithDescription:(NSEntityDescription *)entityDescription
                                     inContext:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = entityDescription;
    
    if (!entity) {
        entity = [self QM_entityDescriptionInContext:context];
    }
    
    NSManagedObject *managedObject = [[self alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:context];
    
    if ([managedObject respondsToSelector:@selector(QM_awakeFromCreation)]) {
        [managedObject QM_awakeFromCreation];
    }
    
    return managedObject;
}

- (BOOL)QM_isTemporaryObject {
    return [[self objectID] isTemporaryID];
}

//MARK: - Deleting Entities

- (BOOL)QM_isEntityDeleted {
    return [self isDeleted] || [self managedObjectContext] == nil;
}

- (BOOL)QM_deleteEntity {
    
    return [self QM_deleteEntityInContext:[self managedObjectContext]];
}

- (BOOL)QM_deleteEntityInContext:(NSManagedObjectContext *)context {
    
    NSError *retrieveExistingObjectError;
    NSManagedObject *objectInContext = [context existingObjectWithID:[self objectID]
                                                               error:&retrieveExistingObjectError];
    
    [[retrieveExistingObjectError QM_coreDataDescription] QM_logToConsole];
    [context deleteObject:objectInContext];
    
    return [objectInContext QM_isEntityDeleted];
}

+ (BOOL)QM_deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestAllWithPredicate:predicate];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    
    NSArray *objectsToTruncate = [self QM_executeFetchRequest:request inContext:context];
    
    for (NSManagedObject *objectToTruncate in objectsToTruncate) {
        
        [objectToTruncate QM_deleteEntityInContext:context];
    }
    
    return YES;
}

+ (BOOL)QM_truncateAllInContext:(NSManagedObjectContext *)context {
    
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

//MARK: - Sorting Entities

+ (NSArray *)QM_ascendingSortDescriptors:(NSArray *)attributesToSortBy {
    
    return [self QM_sortAscending:YES attributes:attributesToSortBy];
}

+ (NSArray *)QM_descendingSortDescriptors:(NSArray *)attributesToSortBy {
    
    return [self QM_sortAscending:NO attributes:attributesToSortBy];
}

+ (NSArray *)QM_sortAscending:(BOOL)ascending attributes:(NSArray *)attributesToSortBy {
    
    NSMutableArray *attributes =
    [NSMutableArray arrayWithCapacity:attributesToSortBy.count];
    
    for (NSString *attributeName in attributesToSortBy) {
        
        NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:attributeName
                                    ascending:ascending];
        [attributes addObject:sortDescriptor];
    }
    
    return attributes;
}

//MARK: - Working Across Contexts

- (void)QM_refresh {
    
    [[self managedObjectContext] refreshObject:self mergeChanges:YES];
}

- (void)QM_obtainPermanentObjectID {
    
    if (self.objectID.isTemporaryID) {
        NSError *error = nil;
        
        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:@[self]
                                                                           error:&error];
        if (!success){
            [[error QM_coreDataDescription] QM_logToConsole];
        }
    }
}

- (instancetype)QM_inContext:(NSManagedObjectContext *)otherContext {
    
    NSManagedObject *inContext = nil;
    NSManagedObjectID *objectID = self.objectID;
    
    if (otherContext == self.managedObjectContext) {
        
        inContext = self;
    }
    else if (objectID.isTemporaryID) {
        
        NSString *reason = [NSString stringWithFormat:@"Cannot load a temporary object '%@' [%@] across managed object contexts. Please obtain a permanent ID for this object first.",
                            self, objectID];
        
        @throw [NSException exceptionWithName:NSObjectInaccessibleException
                                       reason:reason
                                     userInfo:@{@"object" : self}];
    }
    else {
        
        inContext = [otherContext objectRegisteredForID:objectID];  //see if its already there
        
        if (!inContext) {
            
            NSError *error = nil;
            inContext = [otherContext existingObjectWithID:objectID
                                                     error:&error];
            if (!inContext) {
                QMCDLogWarn(@"Did not find object %@ in context '%@': %@",
                            self, [otherContext QM_description], error);
            }
        }
    }
    return inContext;
}

- (instancetype)QM_inContextIfTemporaryObject:(NSManagedObjectContext *)otherContext {
    
    if (self.objectID.isTemporaryID) {
        
        return self;
    }
    else {
        
        return [self QM_inContext:otherContext];
    }
}

//MARK: - Validation

- (BOOL)QM_isValidForInsert {
    
    NSError *error = nil;
    BOOL isValid = [self validateForInsert:&error];
    
    if (!isValid) {
        [[error QM_coreDataDescription] QM_logToConsole];
    }
    
    return isValid;
}

- (BOOL)QM_isValidForUpdate {
    
    NSError *error = nil;
    BOOL isValid = [self validateForUpdate:&error];
    
    if (!isValid) {
        [[error QM_coreDataDescription] QM_logToConsole];
    }
    
    return isValid;
}

@end

