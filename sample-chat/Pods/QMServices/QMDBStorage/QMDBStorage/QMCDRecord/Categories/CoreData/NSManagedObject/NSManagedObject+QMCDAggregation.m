//
//  NSManagedObject+QMCDAggregation.m
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"
#import "NSManagedObject+QMCDAggregation.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSManagedObject+QMCDRequests.h"
#import "NSManagedObject+QMCDRecord.h"
#import "NSManagedObject+QMCDFinders.h"
#import "NSError+QMCDRecordErrorHandling.h"

@implementation NSManagedObject (QMCDAggregation)

//MARK: -
//MARK: Number of Entities

+ (NSNumber *)QM_numberOfEntitiesWithContext:(NSManagedObjectContext *)context {
    
    return @([self QM_countOfEntitiesWithContext:context]);
}

+ (NSNumber *)QM_numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm
                                     inContext:(NSManagedObjectContext *)context {
    
    return @([self QM_countOfEntitiesWithPredicate:searchTerm
                                         inContext:context]);
}

+ (NSUInteger)QM_countOfEntitiesWithContext:(NSManagedObjectContext *)context {
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:[self QM_requestAll]
                                               error:&error];
    [[error QM_coreDataDescription] QM_logToConsole];
    
    return count;
}

+ (NSUInteger)QM_countOfEntitiesWithPredicate:(NSPredicate *)searchFilter
                                    inContext:(NSManagedObjectContext *)context {
    
    NSError *error = nil;
    NSFetchRequest *request = [self QM_requestAll];
    request.includesPendingChanges = YES;
    
    [request setPredicate:searchFilter];
    
    NSUInteger count = [context countForFetchRequest:request error:&error];
    [[error QM_coreDataDescription] QM_logToConsole];
    
    return count;
}

+ (BOOL)QM_hasAtLeastOneEntityInContext:(NSManagedObjectContext *)context {
    
    return [[self QM_numberOfEntitiesWithContext:context] intValue] > 0;
}

- (id)QM_minValueFor:(NSString *)property {
    
    NSManagedObject *obj =
    [[self class] QM_findFirstByAttribute:property
                                withValue:[NSString stringWithFormat:@"min(%@)", property]
                                inContext:self.managedObjectContext];
    
    return [obj valueForKey:property];
}

- (id)QM_maxValueFor:(NSString *)property {
    
    NSManagedObject *obj =
    [[self class] QM_findFirstByAttribute:property
                                withValue:[NSString stringWithFormat:@"max(%@)", property]
                                inContext:[self managedObjectContext]];
    
    return [obj valueForKey:property];
}

- (id)QM_objectWithMinValueFor:(NSString *)property
                     inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [[self class] QM_requestAll];
    
    request.predicate =
    [NSPredicate predicateWithFormat:@"SELF = %@ AND %K = min(%@)",
     self, property, property];
    
    return [[self class] QM_executeFetchRequestAndReturnFirstObject:request
                                                          inContext:context];
}

- (id)QM_objectWithMinValueFor:(NSString *)property {
    
    return [self QM_objectWithMinValueFor:property
                                inContext:self.managedObjectContext];
}

+ (NSArray *)QM_aggregateOperation:(NSString *)collectionOperator
                       onAttribute:(NSString *)attributeName
                     withPredicate:(NSPredicate *)predicate
                           groupBy:(NSString *)groupingKeyPath
                         inContext:(NSManagedObjectContext *)context {
    
    NSExpression *expression =
    [NSExpression expressionForFunction:collectionOperator
                              arguments:
     [NSArray arrayWithObject:[NSExpression expressionForKeyPath:attributeName]]];
    
    NSExpressionDescription *expressionDescription =
    [[NSExpressionDescription alloc] init];
    
    expressionDescription.name = @"result";
    expressionDescription.expression = expression;
    
    NSAttributeDescription *attributeDescription =
    [[self QM_entityDescriptionInContext:context].attributesByName
     objectForKey:attributeName];
    
    expressionDescription.expressionResultType = attributeDescription.attributeType;
    
    NSArray *properties = [NSArray arrayWithObjects:groupingKeyPath, expressionDescription, nil];
    
    NSFetchRequest *fetchRequest = [self QM_requestAllWithPredicate:predicate];
    [fetchRequest setPropertiesToFetch:properties];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:groupingKeyPath]];
    
    NSArray *results = [self QM_executeFetchRequest:fetchRequest inContext:context];
    
    return results;
}

@end
