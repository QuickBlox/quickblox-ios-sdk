//
//  NSManagedObject+QMCDFinders.m
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSManagedObject+QMCDFinders.h"
#import "NSManagedObject+QMCDRequests.h"
#import "NSManagedObject+QMCDRecord.h"
#import "QMCDRecordStack.h"

@implementation NSManagedObject (QMCDFinders)

+ (NSArray *) QM_findAllInContext:(NSManagedObjectContext *)context
{
	return [self QM_executeFetchRequest:[self QM_requestAll] inContext:context];
}

+ (NSArray *) QM_findAll
{
	return [self QM_findAllInContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self QM_requestAllSortedBy:sortTerm ascending:ascending];

	return [self QM_executeFetchRequest:request inContext:context];
}

+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
	return [self QM_findAllSortedBy:sortTerm
                          ascending:ascending
                          inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self QM_requestAllSortedBy:sortTerm
                                                ascending:ascending
                                            withPredicate:searchTerm];

	return [self QM_executeFetchRequest:request inContext:context];
}

+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm
{
	return [self QM_findAllSortedBy:sortTerm
                          ascending:ascending
                      withPredicate:searchTerm
                          inContext:[[QMCDRecordStack defaultStack] context]];
}


+ (NSArray *) QM_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self QM_requestAll];
	[request setPredicate:searchTerm];

	return [self QM_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *) QM_findAllWithPredicate:(NSPredicate *)searchTerm
{
	return [self QM_findAllWithPredicate:searchTerm
                               inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending;
{
    return [self QM_selectAttribute:attribute ascending:ascending inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestAllSortedBy:attribute ascending:ascending];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObject:attribute]];
    NSArray *results = [self QM_executeFetchRequest:request inContext:context];

    return [results valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", attribute]];
}

+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending withPredicate:(NSPredicate *)predicate;
{
    return [self QM_selectAttribute:attribute ascending:ascending withPredicate:predicate inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestAllSortedBy:attribute ascending:ascending withPredicate:predicate];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObject:attribute]];
    NSArray *results = [self QM_executeFetchRequest:request inContext:context];

    return [results valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", attribute]];
}

+ (instancetype) QM_findFirst;
{
	return [self QM_findFirstInContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstInContext:(NSManagedObjectContext *)context;
{
	NSFetchRequest *request = [self QM_requestAll];

	return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue;
{
	return [self QM_findFirstByAttribute:attribute
                               withValue:searchValue
                               inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self QM_requestFirstByAttribute:attribute withValue:searchValue];

	return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue orderedBy:(NSString *)orderedBy ascending:(BOOL)ascending;
{
    return [self QM_findFirstByAttribute:attribute withValue:searchValue orderedBy:orderedBy ascending:ascending inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue orderedBy:(NSString *)orderedBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestFirstByAttribute:attribute withValue:searchValue];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:orderedBy ascending:ascending];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestAllSortedBy:attribute ascending:ascending];
    [request setFetchLimit:1];

    return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending;
{
    return [self QM_findFirstOrderedByAttribute:attribute
                                      ascending:ascending
                                      inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstOrCreateByAttribute:(NSString *)attribute withValue:(id)searchValue
{
    return [self QM_findFirstOrCreateByAttribute:attribute
                                       withValue:searchValue
                                       inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstOrCreateByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
    id result = [self QM_findFirstByAttribute:attribute
                                    withValue:searchValue
                                    inContext:context];

    if (result != nil) {
        return result;
    }

    result = [self QM_createEntityInContext:context];
    [result setValue:searchValue forKey:attribute];

    return result;
}

+ (id) QM_findLargestValueForAttribute:(NSString *)attribute withPredicate:(NSPredicate *)predicate;
{
    return [self QM_findLargestValueForAttribute:attribute withPredicate:predicate inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_findLargestValueForAttribute:(NSString *)attribute withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestAllSortedBy:attribute ascending:NO];
    [request setFetchLimit:1];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[attribute]];
    [request setPredicate:predicate];

    NSDictionary *results = [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
    id value = [results valueForKey:attribute];

    return value;
}

+ (id) QM_findLargestValueForAttribute:(NSString *)attribute;
{
    return [self QM_findLargestValueForAttribute:attribute inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_findLargestValueForAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context;
{
    return [self QM_findLargestValueForAttribute:attribute withPredicate:nil inContext:context];
}

+ (id) QM_findSmallestValueForAttribute:(NSString *)attribute;
{
    return [self QM_findSmallestValueForAttribute:attribute inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (id) QM_findSmallestValueForAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestAllSortedBy:attribute ascending:YES];
    [request setFetchLimit:1];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[attribute]];

    NSDictionary *results = [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
    id value = [results valueForKey:attribute];

    return value;
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm;
{
    return [self QM_findFirstWithPredicate:searchTerm inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self QM_requestFirstWithPredicate:searchTerm];

    return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)property ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
	NSFetchRequest *request = [self QM_requestAllSortedBy:property ascending:ascending withPredicate:searchTerm];

	return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending;
{
	return [self QM_findFirstWithPredicate:searchterm
                                  sortedBy:property
                                 ascending:ascending
                                 inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context;
{
	NSFetchRequest *request = [self QM_requestAll];
	[request setPredicate:searchTerm];
	[request setPropertiesToFetch:attributes];

	return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes;
{
	return [self QM_findFirstWithPredicate:searchTerm
                     andRetrieveAttributes:attributes
                                 inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ...
{
	NSFetchRequest *request = [self QM_requestAllSortedBy:sortBy
                                                ascending:ascending
                                            withPredicate:searchTerm];
	[request setPropertiesToFetch:[self QM_propertiesNamed:attributes]];

	return [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending andRetrieveAttributes:(id)attributes, ...
{
	return [self QM_findFirstWithPredicate:searchTerm
                                  sortedBy:sortBy
                                 ascending:ascending
                                 inContext:[[QMCDRecordStack defaultStack] context]
                     andRetrieveAttributes:attributes];
}

+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self QM_requestAllWhere:attribute isEqualTo:searchValue];

	return [self QM_executeFetchRequest:request inContext:context];
}

+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue;
{
	return [self QM_findByAttribute:attribute
                          withValue:searchValue
                          inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
	NSPredicate *searchTerm = [NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue];
	NSFetchRequest *request = [self QM_requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm];

	return [self QM_executeFetchRequest:request inContext:context];
}

+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending;
{
	return [self QM_findByAttribute:attribute
                          withValue:searchValue
                         andOrderBy:sortTerm
                          ascending:ascending
                          inContext:[[QMCDRecordStack defaultStack] context]];
}

@end
