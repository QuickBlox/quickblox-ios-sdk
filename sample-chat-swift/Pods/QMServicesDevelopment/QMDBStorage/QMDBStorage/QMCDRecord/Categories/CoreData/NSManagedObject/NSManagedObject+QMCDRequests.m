//
//  NSManagedObject+QMCDRequests.m
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSManagedObject+QMCDRequests.h"
#import "NSManagedObject+QMCDRecord.h"
#import "QMCDRecordStack.h"
#import "QMCDRecordLogging.h"

static NSUInteger defaultBatchSize = 20;

NSArray *QM_NSSortDescriptorsFromString(NSString *string, BOOL defaultAscendingValue);

@implementation NSManagedObject (QMCDRequests)

#pragma mark - Global Options

+ (void) QM_setDefaultBatchSize:(NSUInteger)newBatchSize
{
	@synchronized(self)
	{
		defaultBatchSize = newBatchSize;
	}
}

+ (NSUInteger) QM_defaultBatchSize
{
	return defaultBatchSize;
}

#pragma mark - Fetch Request Creation

+ (NSFetchRequest *) QM_requestAll
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self QM_entityName]];
    return request;
}

+ (NSFetchRequest *) QM_requestAllWithPredicate:(NSPredicate *)predicate;
{
    NSFetchRequest *request = [self QM_requestAll];
    [request setPredicate:predicate];
    
    return request;
}

+ (NSFetchRequest *) QM_requestAllWhere:(NSString *)attributeName isEqualTo:(id)value;
{
    NSFetchRequest *request = [self QM_requestAll];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attributeName, value]];
    
    return request;
}

+ (NSFetchRequest *) QM_requestFirstWithPredicate:(NSPredicate *)predicate;
{
    NSFetchRequest *request = [self QM_requestAll];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    return request;
}

+ (NSFetchRequest *) QM_requestFirstByAttribute:(NSString *)attributeName withValue:(id)value;
{
    NSFetchRequest *request = [self QM_requestAllWhere:attributeName isEqualTo:value];
    [request setFetchLimit:1];
    
    return request;
}

+ (NSFetchRequest *) QM_requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
{
    return [self QM_requestAllSortedBy:sortTerm
                             ascending:ascending
                         withPredicate:nil];
}

+ (NSFetchRequest *) QM_requestAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)predicate;
{
	NSFetchRequest *request = [self QM_requestAll];
	if (predicate)
    {
        [request setPredicate:predicate];
    }
	[request setFetchBatchSize:[self QM_defaultBatchSize]];
	[request setSortDescriptors:QM_NSSortDescriptorsFromString(sortTerm, ascending)];
    
	return request;
}

@end

NSArray *QM_NSSortDescriptorsFromString(NSString *sortTerm, BOOL defaultAscendingValue)
{
    NSMutableArray* sortDescriptors = [[NSMutableArray alloc] init];
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];

    for (__strong NSString* sortKey in sortKeys)
    {
        BOOL ascending = defaultAscendingValue;
        NSArray* sortComponents = [sortKey componentsSeparatedByString:@":"];

        sortKey = sortComponents[0];
        if ([sortComponents count] > 1)
        {
            NSNumber* customAscending = [sortComponents lastObject];
            ascending = [customAscending boolValue];
        }

        QMCDLogCVerbose(@"- Sorting %@ %@", sortKey, ascending ? @"Ascending": @"Descending");
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }

    return [NSArray arrayWithArray:sortDescriptors];
}
