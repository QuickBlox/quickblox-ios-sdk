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

+ (NSArray *)QM_findAllInContext:(NSManagedObjectContext *)context {
    
    return [self QM_executeFetchRequest:[self QM_requestAll]
                              inContext:context];
}

+ (NSArray *)QM_findAllSortedBy:(NSString *)sortTerm
                      ascending:(BOOL)ascending
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request =
    [self QM_requestAllSortedBy:sortTerm
                      ascending:ascending];
    
    return [self QM_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *)QM_findAllSortedBy:(NSString *)sortTerm
                      ascending:(BOOL)ascending
                  withPredicate:(NSPredicate *)searchTerm
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request =
    [self QM_requestAllSortedBy:sortTerm
                      ascending:ascending
                  withPredicate:searchTerm];
    
    return [self QM_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *)QM_findAllSortedBy:(NSString *)sortTerm
                      ascending:(BOOL)ascending
                  withPredicate:(NSPredicate *)searchTerm
                         offset:(NSUInteger)offset
                          limit:(NSUInteger)limit
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request =
    [self QM_requestAllSortedBy:sortTerm
                      ascending:ascending
                  withPredicate:searchTerm];
    request.fetchOffset = offset;
    request.fetchLimit = limit;
    return [self QM_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *)QM_findAllWithPredicate:(NSPredicate *)searchTerm
                           inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestAll];
    request.predicate = searchTerm;
    
    return [self QM_executeFetchRequest:request
                              inContext:context];
}


+ (instancetype)QM_findFirstByAttribute:(NSString *)attribute
                              withValue:(id)searchValue
                              inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestFirstByAttribute:attribute
                                                     withValue:searchValue];
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (instancetype)QM_findFirstByAttribute:(NSString *)attribute
                              withValue:(id)searchValue
                              orderedBy:(NSString *)orderedBy
                              ascending:(BOOL)ascending
                              inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestFirstByAttribute:attribute
                                                     withValue:searchValue];
    NSSortDescriptor *sortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:orderedBy
                                ascending:ascending];
    
    request.sortDescriptors = @[sortDescriptor];
    
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (instancetype)QM_findFirstOrderedByAttribute:(NSString *)attribute
                                     ascending:(BOOL)ascending
                                     inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestAllSortedBy:attribute
                                                ascending:ascending];
    request.fetchLimit = 1;
    
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (instancetype)QM_findFirstOrCreateByAttribute:(NSString *)attribute
                                      withValue:(id)searchValue
                                      inContext:(NSManagedObjectContext *)context {
    
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

+ (instancetype)QM_findFirstWithPredicate:(NSPredicate *)searchTerm
                                inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestFirstWithPredicate:searchTerm];
    
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (instancetype)QM_findFirstWithPredicate:(NSPredicate *)searchTerm
                                 sortedBy:(NSString *)property
                                ascending:(BOOL)ascending
                                inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestAllSortedBy:property
                                                ascending:ascending
                                            withPredicate:searchTerm];
    
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (instancetype)QM_findFirstWithPredicate:(NSPredicate *)searchTerm
                    andRetrieveAttributes:(NSArray *)attributes
                                inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestAll];
    [request setPredicate:searchTerm];
    [request setPropertiesToFetch:attributes];
    
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (instancetype)QM_findFirstWithPredicate:(NSPredicate *)searchTerm
                                 sortedBy:(NSString *)sortBy
                                ascending:(BOOL)ascending
                                inContext:(NSManagedObjectContext *)context
                    andRetrieveAttributes:(id)attributes, ... {
    
    NSFetchRequest *request = [self QM_requestAllSortedBy:sortBy
                                                ascending:ascending
                                            withPredicate:searchTerm];
    
    [request setPropertiesToFetch:[self QM_propertiesNamed:attributes
                                                 inContext:context]];
    
    return [self QM_executeFetchRequestAndReturnFirstObject:request
                                                  inContext:context];
}

+ (NSArray *)QM_findByAttribute:(NSString *)attribute
                      withValue:(id)searchValue
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self QM_requestAllWhere:attribute
                                             isEqualTo:searchValue];
    
    return [self QM_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *)QM_findByAttribute:(NSString *)attribute
                      withValue:(id)searchValue
                     andOrderBy:(NSString *)sortTerm
                      ascending:(BOOL)ascending
                      inContext:(NSManagedObjectContext *)context {
    
    NSPredicate *searchTerm =
    [NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue];
    NSFetchRequest *request =
    [self QM_requestAllSortedBy:sortTerm
                      ascending:ascending
                  withPredicate:searchTerm];
    
    return [self QM_executeFetchRequest:request
                              inContext:context];
}

@end
