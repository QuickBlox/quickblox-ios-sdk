//
//  NSManagedObject+QMCDFetching.h
//  QMCDRecord
//
//  Created by Injoit on 9/15/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 Category methods on NSManagedObject to make working with NSFetchedResultsControllers easier.

 @since Available in v3.0 and later.
 */
@interface NSManagedObject (QMCDFetching)

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) QM_fetchController:(NSFetchRequest *)request delegate:(id<NSFetchedResultsControllerDelegate>)delegate useFileCache:(BOOL)useFileCache groupedBy:(NSString *)groupKeyPath inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *) QM_fetchAllSortedBy:(NSString *)sortTerm
                                           ascending:(BOOL)ascending
                                       withPredicate:(NSPredicate *)searchTerm
                                             groupBy:(NSString *)groupingKeyPath
                                            delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
+ (NSFetchedResultsController *) QM_fetchAllSortedBy:(NSString *)sortTerm
                                           ascending:(BOOL)ascending
                                       withPredicate:(NSPredicate *)searchTerm
                                             groupBy:(NSString *)groupingKeyPath
                                            delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                           inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;

#endif

@end
