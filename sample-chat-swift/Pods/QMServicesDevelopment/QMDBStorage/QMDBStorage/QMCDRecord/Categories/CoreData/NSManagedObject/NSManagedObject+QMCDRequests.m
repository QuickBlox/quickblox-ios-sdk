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

//MARK: - Global Options

+ (void)QM_setDefaultBatchSize:(NSUInteger)newBatchSize {
    
    @synchronized(self) {
        defaultBatchSize = newBatchSize;
    }
}

+ (NSUInteger)QM_defaultBatchSize {
    
    return defaultBatchSize;
}

//MARK: - Fetch Request Creation

+ (NSFetchRequest *)QM_requestAll {
    
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:[self QM_entityName]];
    
    return request;
}

+ (NSFetchRequest *)QM_requestAllWithPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *request = [self QM_requestAll];
    request.predicate = predicate;
    
    return request;
}

+ (NSFetchRequest *)QM_requestAllWhere:(NSString *)attributeName
                             isEqualTo:(id)value {
    
    NSFetchRequest *request = [self QM_requestAll];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                         attributeName, value];
    
    return request;
}

+ (NSFetchRequest *)QM_requestFirstWithPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *request = [self QM_requestAll];
    request.predicate = predicate;
    request.fetchLimit = 1;
    
    return request;
}

+ (NSFetchRequest *)QM_requestFirstByAttribute:(NSString *)attributeName
                                     withValue:(id)value {
    
    NSFetchRequest *request = [self QM_requestAllWhere:attributeName
                                             isEqualTo:value];
    request.fetchLimit = 1;
    return request;
}

+ (NSFetchRequest *)QM_requestAllSortedBy:(NSString *)sortTerm
                                ascending:(BOOL)ascending {
    
    return [self QM_requestAllSortedBy:sortTerm
                             ascending:ascending
                         withPredicate:nil];
}

+ (NSFetchRequest *)QM_requestAllSortedBy:(NSString *)sortTerm
                                ascending:(BOOL)ascending
                            withPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *request = [self QM_requestAll];
    request.predicate = predicate;
    request.fetchBatchSize = [self QM_defaultBatchSize];
    request.sortDescriptors = QM_NSSortDescriptorsFromString(sortTerm, ascending);
    
    return request;
}

@end

NSArray *QM_NSSortDescriptorsFromString(NSString *sortTerm, BOOL defaultAscendingValue)
{
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];
    NSMutableArray* sortDescriptors = [NSMutableArray arrayWithCapacity:sortKeys.count];
    
    for (__strong NSString* sortKey in sortKeys)
    {
        BOOL ascending = defaultAscendingValue;
        NSArray* sortComponents = [sortKey componentsSeparatedByString:@":"];
        
        sortKey = sortComponents.firstObject;
        if ([sortComponents count] > 1)
        {
            NSNumber *customAscending = sortComponents.lastObject;
            ascending = customAscending.boolValue;
        }
        
        QMCDLogCVerbose(@"- Sorting %@ %@", sortKey, ascending ? @"Ascending": @"Descending");
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    
    return [NSArray arrayWithArray:sortDescriptors];
}
