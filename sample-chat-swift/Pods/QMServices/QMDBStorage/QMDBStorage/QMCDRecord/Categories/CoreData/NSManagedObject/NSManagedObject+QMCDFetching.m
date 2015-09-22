//
//  NSManagedObject+QMCDFetching.m
//  QMCDRecord
//
//  Created by Injoit on 9/15/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSManagedObject+QMCDFetching.h"
#import "NSManagedObject+QMCDRequests.h"
#import "NSFetchedResultsController+QMCDFetching.h"

#import "QMCDRecordStack.h"

@implementation NSManagedObject (QMCDFetching)

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSString *) QM_fileCacheNameForObject:(id)object;
{
    SEL selector = @selector(fetchedResultsControllerCacheName);
    if ([object respondsToSelector:selector])
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:object];
        [invocation invoke];
        NSString *returnValue = nil;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return [NSString stringWithFormat:@"QMCDRecord-Cache-%@", NSStringFromClass([object class])];
}

+ (NSFetchedResultsController *) QM_fetchController:(NSFetchRequest *)request delegate:(id<NSFetchedResultsControllerDelegate>)delegate useFileCache:(BOOL)useFileCache groupedBy:(NSString *)groupKeyPath inContext:(NSManagedObjectContext *)context
{
    NSString *cacheName = useFileCache ? [self QM_fileCacheNameForObject:delegate] : nil;

	NSFetchedResultsController *controller =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:context
                                          sectionNameKeyPath:groupKeyPath
                                                   cacheName:cacheName];
    controller.delegate = delegate;

    return controller;
}

+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self QM_requestAllSortedBy:sortTerm
                                                ascending:ascending
                                            withPredicate:searchTerm];

    NSFetchedResultsController *controller = [self QM_fetchController:request
                                                             delegate:delegate
                                                         useFileCache:NO
                                                            groupedBy:group
                                                            inContext:context];

    [controller QM_performFetch];
    return controller;
}

+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id)delegate
{
	return [self QM_fetchAllGroupedBy:group
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                             delegate:delegate
                            inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    return [self QM_fetchAllGroupedBy:group
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                             delegate:nil
                            inContext:context];
}

+ (NSFetchedResultsController *) QM_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
    return [self QM_fetchAllGroupedBy:group
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                            inContext:[[QMCDRecordStack defaultStack] context]];
}


+ (NSFetchedResultsController *) QM_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self QM_requestAllSortedBy:sortTerm
                                                ascending:ascending
                                            withPredicate:searchTerm];

	NSFetchedResultsController *controller = [self QM_fetchController:request
                                                             delegate:nil
                                                         useFileCache:NO
                                                            groupedBy:groupingKeyPath
                                                            inContext:[[QMCDRecordStack defaultStack] context]];

    [controller QM_performFetch];
    return controller;
}

+ (NSFetchedResultsController *) QM_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath;
{
    return [self QM_fetchAllSortedBy:sortTerm
                           ascending:ascending
                       withPredicate:searchTerm
                             groupBy:groupingKeyPath
                           inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSFetchedResultsController *) QM_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;
{
	return [self QM_fetchAllGroupedBy:groupingKeyPath
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                             delegate:delegate
                            inContext:context];
}

+ (NSFetchedResultsController *) QM_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
{
	return [self QM_fetchAllSortedBy:sortTerm
                           ascending:ascending
                       withPredicate:searchTerm
                             groupBy:groupingKeyPath
                            delegate:delegate
                           inContext:[[QMCDRecordStack defaultStack] context]];
}

#endif
@end
