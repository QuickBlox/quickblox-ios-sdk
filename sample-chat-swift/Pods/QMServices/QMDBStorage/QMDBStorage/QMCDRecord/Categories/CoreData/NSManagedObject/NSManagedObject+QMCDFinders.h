//
//  NSManagedObject+QMCDFinders.h
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>

@protocol QMCDFinderExtensions <NSObject>

@optional
- (NSString *) fetchedResultsControllerCacheName;

@end

/**
 Category methods to make finding entities easier.

 @since Available since v1.8.
 */
@interface NSManagedObject (QMCDFinders) <QMCDFinderExtensions>

+ (NSArray *) QM_findAll;
+ (NSArray *) QM_findAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm;
+ (NSArray *) QM_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (NSArray *) QM_findAllWithPredicate:(NSPredicate *)searchTerm;
+ (NSArray *) QM_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (instancetype) QM_findFirst;
+ (instancetype) QM_findFirstInContext:(NSManagedObjectContext *)context;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending andRetrieveAttributes:(id)attributes, ...;
+ (instancetype) QM_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ...;
+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue orderedBy:(NSString *)orderedBy ascending:(BOOL)ascending;
+ (instancetype) QM_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue orderedBy:(NSString *)orderedBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (instancetype) QM_findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending;
+ (instancetype) QM_findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

+ (instancetype) QM_findFirstOrCreateByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (instancetype) QM_findFirstOrCreateByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;

+ (id) QM_findLargestValueForAttribute:(NSString *)attribute;
+ (id) QM_findLargestValueForAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context;
+ (id) QM_findLargestValueForAttribute:(NSString *)attribute withPredicate:(NSPredicate *)predicate;
+ (id) QM_findLargestValueForAttribute:(NSString *)attribute withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (id) QM_findSmallestValueForAttribute:(NSString *)attribute;
+ (id) QM_findSmallestValueForAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context;

+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending;
+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending withPredicate:(NSPredicate *)predicate;
+ (id) QM_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending;
+ (NSArray *) QM_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

@end
