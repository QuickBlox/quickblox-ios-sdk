#ifdef QM_SHORTHAND

#import "QMCDRecordShorthand.h"
#import "QMCDRecord.h"


@implementation NSManagedObject (QMCDAggregationShortHand)

+ (NSNumber *) numberOfEntities;
{
    return [self QM_numberOfEntities];
}

+ (NSNumber *) numberOfEntitiesWithContext:(NSManagedObjectContext *)context;
{
    return [self QM_numberOfEntitiesWithContext:context];
}

+ (NSNumber *) numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm;
{
    return [self QM_numberOfEntitiesWithPredicate:searchTerm];
}

+ (NSNumber *) numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
{
    return [self QM_numberOfEntitiesWithPredicate:searchTerm inContext:context];
}

+ (NSUInteger) countOfEntities;
{
    return [self QM_countOfEntities];
}

+ (NSUInteger) countOfEntitiesWithContext:(NSManagedObjectContext *)context;
{
    return [self QM_countOfEntitiesWithContext:context];
}

+ (NSUInteger) countOfEntitiesWithPredicate:(NSPredicate *)searchFilter;
{
    return [self QM_countOfEntitiesWithPredicate:searchFilter];
}

+ (NSUInteger) countOfEntitiesWithPredicate:(NSPredicate *)searchFilter inContext:(NSManagedObjectContext *)context;
{
    return [self QM_countOfEntitiesWithPredicate:searchFilter inContext:context];
}

+ (BOOL) hasAtLeastOneEntity;
{
    return [self QM_hasAtLeastOneEntity];
}

+ (BOOL) hasAtLeastOneEntityInContext:(NSManagedObjectContext *)context;
{
    return [self QM_hasAtLeastOneEntityInContext:context];
}

+ (NSNumber *)aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
{
    return [self QM_aggregateOperation:function onAttribute:attributeName withPredicate:predicate inContext:context];
}

+ (NSNumber *)aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate;
{
    return [self QM_aggregateOperation:function onAttribute:attributeName withPredicate:predicate];
}

- (id) objectWithMinValueFor:(NSString *)property;
{
    return [self QM_objectWithMinValueFor:property];
}

- (id) objectWithMinValueFor:(NSString *)property inContext:(NSManagedObjectContext *)context;
{
    return [self QM_objectWithMinValueFor:property inContext:context];
}

@end


@implementation NSManagedObject (QMCDFetchingShortHand)

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
{
    return [self QM_fetchAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm groupBy:groupingKeyPath delegate:delegate];
}

#endif /* TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR */

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;
{
    return [self QM_fetchAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm groupBy:groupingKeyPath delegate:delegate inContext:context];
}

#endif /* TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR */

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
{
    return [self QM_fetchAllGroupedBy:group withPredicate:searchTerm sortedBy:sortTerm ascending:ascending];
}

#endif /* TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR */

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    return [self QM_fetchAllGroupedBy:group withPredicate:searchTerm sortedBy:sortTerm ascending:ascending inContext:context];
}

#endif /* TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR */

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
{
    return [self QM_fetchAllGroupedBy:group withPredicate:searchTerm sortedBy:sortTerm ascending:ascending delegate:delegate];
}

#endif /* TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR */

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;
{
    return [self QM_fetchAllGroupedBy:group withPredicate:searchTerm sortedBy:sortTerm ascending:ascending delegate:delegate inContext:context];
}

#endif /* TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR */

@end


@implementation NSManagedObject (QMCDRecordShortHand)

+ (NSArray *) executeFetchRequest:(NSFetchRequest *)request;
{
    return [self QM_executeFetchRequest:request];
}

+ (NSArray *) executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;
{
    return [self QM_executeFetchRequest:request inContext:context];
}

+ (id) executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request;
{
    return [self QM_executeFetchRequestAndReturnFirstObject:request];
}

+ (id) executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;
{
    return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (NSEntityDescription *) entityDescription;
{
    return [self QM_entityDescription];
}

+ (NSEntityDescription *) entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    return [self QM_entityDescriptionInContext:context];
}

+ (NSArray *) propertiesNamed:(NSArray *)properties;
{
    return [self QM_propertiesNamed:properties];
}

+ (instancetype) createEntity;
{
    return [self QM_createEntity];
}

+ (instancetype) createEntityInContext:(NSManagedObjectContext *)context;
{
    return [self QM_createEntityInContext:context];
}

+ (instancetype) createEntityWithDescription:(NSEntityDescription *)entityDescription inContext:(NSManagedObjectContext *)context;
{
    return [self QM_createEntityWithDescription:entityDescription inContext:context];
}

- (BOOL) isEntityDeleted;
{
    return [self QM_isEntityDeleted];
}

- (BOOL) deleteEntity;
{
    return [self QM_deleteEntity];
}

- (BOOL) deleteEntityInContext:(NSManagedObjectContext *)context;
{
    return [self QM_deleteEntityInContext:context];
}

+ (BOOL) deleteAllMatchingPredicate:(NSPredicate *)predicate;
{
    return [self QM_deleteAllMatchingPredicate:predicate];
}

+ (BOOL) deleteAllMatchingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
{
    return [self QM_deleteAllMatchingPredicate:predicate inContext:context];
}

+ (BOOL) truncateAll;
{
    return [self QM_truncateAll];
}

+ (BOOL) truncateAllInContext:(NSManagedObjectContext *)context;
{
    return [self QM_truncateAllInContext:context];
}

+ (NSArray *) ascendingSortDescriptors:(NSArray *)attributesToSortBy;
{
    return [self QM_ascendingSortDescriptors:attributesToSortBy];
}

+ (NSArray *) descendingSortDescriptors:(NSArray *)attributesToSortBy;
{
    return [self QM_descendingSortDescriptors:attributesToSortBy];
}

- (void) obtainPermanentObjectID;
{
    return [self QM_obtainPermanentObjectID];
}

- (void) refresh;
{
    return [self QM_refresh];
}

- (instancetype) inContext:(NSManagedObjectContext *)otherContext;
{
    return [self QM_inContext:otherContext];
}

- (instancetype) inContextIfTemporaryObject:(NSManagedObjectContext *)otherContext;
{
    return [self QM_inContextIfTemporaryObject:otherContext];
}

- (BOOL) isValidForInsert;
{
    return [self QM_isValidForInsert];
}

- (BOOL) isValidForUpdate;
{
    return [self QM_isValidForUpdate];
}

@end


@implementation NSManagedObject (QMCDRecordOptionalShortHand)

- (void) awakeFromCreation;
{
    return [self QM_awakeFromCreation];
}

@end


@implementation NSManagedObject (QMCDRecordDeprecatedShortHand)

+ (instancetype) createInContext:(NSManagedObjectContext *)context
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self QM_createInContext:context];
#pragma clang diagnostic pop
}

- (BOOL) deleteInContext:(NSManagedObjectContext *)context
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self QM_deleteInContext:context];
#pragma clang diagnostic pop
}

- (instancetype) inContextIfTempObject:(NSManagedObjectContext *)otherContext
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self QM_inContextIfTempObject:otherContext];
#pragma clang diagnostic pop
}

@end


@implementation NSManagedObject (QMCDRequestsShortHand)

+ (NSUInteger) defaultBatchSize;
{
    return [self QM_defaultBatchSize];
}

+ (void) setDefaultBatchSize:(NSUInteger)newBatchSize;
{
    return [self QM_setDefaultBatchSize:newBatchSize];
}

+ (NSFetchRequest *) requestAll;
{
    return [self QM_requestAll];
}

+ (NSFetchRequest *) requestAllWithPredicate:(NSPredicate *)searchTerm;
{
    return [self QM_requestAllWithPredicate:searchTerm];
}

+ (NSFetchRequest *) requestAllWhere:(NSString *)property isEqualTo:(id)value;
{
    return [self QM_requestAllWhere:property isEqualTo:value];
}

+ (NSFetchRequest *) requestFirstWithPredicate:(NSPredicate *)searchTerm;
{
    return [self QM_requestFirstWithPredicate:searchTerm];
}

+ (NSFetchRequest *) requestFirstByAttribute:(NSString *)attribute withValue:(id)searchValue;
{
    return [self QM_requestFirstByAttribute:attribute withValue:searchValue];
}

+ (NSFetchRequest *) requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
{
    return [self QM_requestAllSortedBy:sortTerm ascending:ascending];
}

+ (NSFetchRequest *) requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm;
{
    return [self QM_requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm];
}

@end


@implementation NSManagedObjectContext (QMCDObservingShortHand)

- (void) observeContext:(NSManagedObjectContext *)otherContext;
{
    return [self QM_observeContextDidSave:otherContext];
}

- (void) stopObservingContext:(NSManagedObjectContext *)otherContext;
{
    return [self QM_stopObservingContextDidSave:otherContext];
}

- (void) observeContextOnMainThread:(NSManagedObjectContext *)otherContext;
{
    return [self QM_observeContextOnMainThread:otherContext];
}

- (void) observeiCloudChangesInCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
    return [self QM_observeiCloudChangesInCoordinator:coordinator];
}

- (void) stopObservingiCloudChangesInCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
    return [self QM_stopObservingiCloudChangesInCoordinator:coordinator];
}

@end


@implementation NSManagedObjectContext (QMCDRecordShortHand)

- (void) obtainPermanentIDsForObjects:(NSArray *)objects;
{
    return [self QM_obtainPermanentIDsForObjects:objects];
}

+ (NSManagedObjectContext *) context
{
    return [self QM_context];
}

+ (NSManagedObjectContext *) mainQueueContext;
{
    return [self QM_mainQueueContext];
}

+ (NSManagedObjectContext *) privateQueueContext;
{
    return [self QM_privateQueueContext];
}

+ (NSManagedObjectContext *) confinementContext;
{
    return [self QM_confinementContext];
}

+ (NSManagedObjectContext *) confinementContextWithParent:(NSManagedObjectContext *)parentContext;
{
    return [self QM_confinementContextWithParent:parentContext];
}

+ (NSManagedObjectContext *) privateQueueContextWithStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator
{
    return [self QM_privateQueueContextWithStoreCoordinator:coordinator];
}

- (NSString *) parentChain;
{
    return [self QM_parentChain];
}

- (void) setWorkingName:(NSString *)workingName;
{
    return [self QM_setWorkingName:workingName];
}

- (NSString *) workingName;
{
    return [self QM_workingName];
}

@end


@implementation NSManagedObjectContext (QMCDSavesShortHand)

- (void) saveOnlySelfWithCompletion:(MRSaveCompletionHandler)completion;
{
    return [self QM_saveOnlySelfWithCompletion:completion];
}

- (void) saveToPersistentStoreWithCompletion:(MRSaveCompletionHandler)completion;
{
    return [self QM_saveToPersistentStoreWithCompletion:completion];
}

- (BOOL) saveOnlySelfAndWait;
{
    return [self QM_saveOnlySelfAndWait];
}

- (BOOL) saveOnlySelfAndWaitWithError:(NSError **)error;
{
    return [self QM_saveOnlySelfAndWaitWithError:error];
}

- (BOOL) saveToPersistentStoreAndWait;
{
    return [self QM_saveToPersistentStoreAndWait];
}

- (BOOL) saveToPersistentStoreAndWaitWithError:(NSError **)error;
{
    return [self QM_saveToPersistentStoreAndWaitWithError:error];
}

@end


@implementation NSManagedObjectModel (QMCDRecordShortHand)

+ (NSManagedObjectModel *) managedObjectModelAtURL:(NSURL *)url;
{
    return [self QM_managedObjectModelAtURL:url];
}

+ (NSManagedObjectModel *) mergedObjectModelFromMainBundle;
{
    return [self QM_mergedObjectModelFromMainBundle];
}

+ (NSManagedObjectModel *) managedObjectModelNamed:(NSString *)modelFileName;
{
    return [self QM_managedObjectModelNamed:modelFileName];
}

+ (NSManagedObjectModel *) newModelNamed:(NSString *) modelName inBundleNamed:(NSString *) bundleName
{
    return [self QM_newModelNamed: modelName inBundleNamed: bundleName];
}

@end


@implementation NSPersistentStoreCoordinator (QMCDAutoMigrationsShortHand)

- (NSPersistentStore *) addAutoMigratingSqliteStoreNamed:(NSString *)storeFileName;
{
    return [self QM_addAutoMigratingSqliteStoreNamed:storeFileName];
}

- (NSPersistentStore *) addAutoMigratingSqliteStoreNamed:(NSString *)storeFileName withOptions:(NSDictionary *)options;
{
    return [self QM_addAutoMigratingSqliteStoreNamed:storeFileName withOptions:options];
}

- (NSPersistentStore *) addAutoMigratingSqliteStoreAtURL:(NSURL *)url;
{
    return [self QM_addAutoMigratingSqliteStoreAtURL:url];
}

- (NSPersistentStore *) addAutoMigratingSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *)options;
{
    return [self QM_addAutoMigratingSqliteStoreAtURL:url withOptions:options];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithAutoMigratingSqliteStoreNamed:(NSString *)storeFileName;
{
    return [self QM_coordinatorWithAutoMigratingSqliteStoreNamed:storeFileName];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithAutoMigratingSqliteStoreAtURL:(NSURL *)url;
{
    return [self QM_coordinatorWithAutoMigratingSqliteStoreAtURL:url];
}

@end


@implementation NSPersistentStoreCoordinator (QMCDInMemoryStoreAdditionsShortHand)

+ (NSPersistentStoreCoordinator *) coordinatorWithInMemoryStore;
{
    return [self QM_coordinatorWithInMemoryStore];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithInMemoryStoreWithModel:(NSManagedObjectModel *)model;
{
    return [self QM_coordinatorWithInMemoryStoreWithModel:model];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithInMemoryStoreWithModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;
{
    return [self QM_coordinatorWithInMemoryStoreWithModel:model withOptions:options];
}

- (NSPersistentStore *) addInMemoryStore;
{
    return [self QM_addInMemoryStore];
}

- (NSPersistentStore *) addInMemoryStoreWithOptions:(NSDictionary *)options;
{
    return [self QM_addInMemoryStoreWithOptions:options];
}

@end


@implementation NSPersistentStoreCoordinator (QMCDManualMigrationsShortHand)

- (NSPersistentStore *) addManuallyMigratingSqliteStoreAtURL:(NSURL *)url;
{
    return [self QM_addManuallyMigratingSqliteStoreAtURL:url];
}

- (NSPersistentStore *) addManuallyMigratingSqliteStoreNamed:(NSString *)storeFileName;
{
    return [self QM_addManuallyMigratingSqliteStoreNamed:storeFileName];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithManuallyMigratingSqliteStoreNamed:(NSString *)storeFileName;
{
    return [self QM_coordinatorWithManuallyMigratingSqliteStoreNamed:storeFileName];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithManuallyMigratingSqliteStoreAtURL:(NSURL *)url;
{
    return [self QM_coordinatorWithManuallyMigratingSqliteStoreAtURL:url];
}

@end


@implementation NSPersistentStoreCoordinator (QMCDRecordShortHand)

+ (NSPersistentStoreCoordinator *) newPersistentStoreCoordinator
{
    return [self QM_newPersistentStoreCoordinator];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore;
{
    return [self QM_coordinatorWithPersistentStore:persistentStore];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore andModel:(NSManagedObjectModel *)model;
{
    return [self QM_coordinatorWithPersistentStore:persistentStore andModel:model];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;
{
    return [self QM_coordinatorWithPersistentStore:persistentStore andModel:model withOptions:options];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithSqliteStoreNamed:(NSString *)storeFileName;
{
    return [self QM_coordinatorWithSqliteStoreNamed:storeFileName];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithSqliteStoreNamed:(NSString *)storeFileName withOptions:(NSDictionary *)options;
{
    return [self QM_coordinatorWithSqliteStoreNamed:storeFileName withOptions:options];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithSqliteStoreNamed:(NSString *)storeFileName andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;
{
    return [self QM_coordinatorWithSqliteStoreNamed:storeFileName andModel:model withOptions:options];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithSqliteStoreAtURL:(NSURL *)url;
{
    return [self QM_coordinatorWithSqliteStoreAtURL:url];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithSqliteStoreAtURL:(NSURL *)url andModel:(NSManagedObjectModel *)model;
{
    return [self QM_coordinatorWithSqliteStoreAtURL:url andModel:model];
}

+ (NSPersistentStoreCoordinator *) coordinatorWithSqliteStoreAtURL:(NSURL *)url andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;
{
    return [self QM_coordinatorWithSqliteStoreAtURL:url andModel:model withOptions:options];
}

- (NSPersistentStore *) addSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *__autoreleasing)options;
{
    return [self QM_addSqliteStoreAtURL:url withOptions:options];
}

- (NSPersistentStore *) addSqliteStoreNamed:(id)storeFileName withOptions:(__autoreleasing NSDictionary *)options;
{
    return [self QM_addSqliteStoreNamed:storeFileName withOptions:options];
}

@end

#endif
