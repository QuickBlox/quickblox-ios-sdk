//
//  NSManagedObject+QMCDAggregation.m
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"
#import "NSManagedObject+QMCDAggregation.h"
#import "NSEntityDescription+QMCDDataImport.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSManagedObject+QMCDRequests.h"
#import "NSManagedObject+QMCDRecord.h"
#import "NSManagedObject+QMCDFinders.h"
#import "NSError+QMCDRecordErrorHandling.h"


@implementation NSManagedObject (QMCDAggregation)

#pragma mark -
#pragma mark Number of Entities

+ (NSNumber *) QM_numberOfEntitiesWithContext:(NSManagedObjectContext *)context
{
	return [NSNumber numberWithUnsignedInteger:[self QM_countOfEntitiesWithContext:context]];
}

+ (NSNumber *) QM_numberOfEntities
{
	return [self QM_numberOfEntitiesWithContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSNumber *) QM_numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    
	return [NSNumber numberWithUnsignedInteger:[self QM_countOfEntitiesWithPredicate:searchTerm inContext:context]];
}

+ (NSNumber *) QM_numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm;
{
	return [self QM_numberOfEntitiesWithPredicate:searchTerm
                                        inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSUInteger) QM_countOfEntities;
{
    return [self QM_countOfEntitiesWithContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSUInteger) QM_countOfEntitiesWithContext:(NSManagedObjectContext *)context;
{
	NSError *error = nil;
	NSUInteger count = [context countForFetchRequest:[self QM_requestAll] error:&error];
    [[error QM_coreDataDescription] QM_logToConsole];

    return count;
}

+ (NSUInteger) QM_countOfEntitiesWithPredicate:(NSPredicate *)searchFilter;
{
    return [self QM_countOfEntitiesWithPredicate:searchFilter inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSUInteger) QM_countOfEntitiesWithPredicate:(NSPredicate *)searchFilter inContext:(NSManagedObjectContext *)context;
{
	NSError *error = nil;
	NSFetchRequest *request = [self QM_requestAll];
	[request setPredicate:searchFilter];
	
	NSUInteger count = [context countForFetchRequest:request error:&error];
    [[error QM_coreDataDescription] QM_logToConsole];

    return count;
}

+ (BOOL) QM_hasAtLeastOneEntity
{
    return [self QM_hasAtLeastOneEntityInContext:[[QMCDRecordStack defaultStack] context]];
}

+ (BOOL) QM_hasAtLeastOneEntityInContext:(NSManagedObjectContext *)context
{
    return [[self QM_numberOfEntitiesWithContext:context] intValue] > 0;
}

- (id) QM_minValueFor:(NSString *)property
{
	NSManagedObject *obj = [[self class] QM_findFirstByAttribute:property
                                                       withValue:[NSString stringWithFormat:@"min(%@)", property]];

	return [obj valueForKey:property];
}

- (id) QM_maxValueFor:(NSString *)property
{
	NSManagedObject *obj = [[self class] QM_findFirstByAttribute:property
                                                       withValue:[NSString stringWithFormat:@"max(%@)", property]];
	
	return [obj valueForKey:property];
}

- (id) QM_objectWithMinValueFor:(NSString *)property inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[self class] QM_requestAll];
    
	NSPredicate *searchFor = [NSPredicate predicateWithFormat:@"SELF = %@ AND %K = min(%@)", self, property, property];
	[request setPredicate:searchFor];
	
	return [[self class] QM_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

- (id) QM_objectWithMinValueFor:(NSString *)property
{
	return [self QM_objectWithMinValueFor:property inContext:[self  managedObjectContext]];
}

+ (id) QM_aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSExpression *ex = [NSExpression expressionForFunction:function 
                                                 arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:attributeName]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    
    // determine the type of attribute, required to set the expression return type    
    NSAttributeDescription *attributeDescription = [[self QM_entityDescriptionInContext:context] QM_attributeDescriptionForName:attributeName];
    [ed setExpressionResultType:[attributeDescription attributeType]];    
    NSArray *properties = [NSArray arrayWithObject:ed];
    
    NSFetchRequest *request = [self QM_requestAllWithPredicate:predicate];
    [request setPropertiesToFetch:properties];
    [request setResultType:NSDictionaryResultType];    
    
    NSDictionary *resultsDictionary = [self QM_executeFetchRequestAndReturnFirstObject:request inContext:context];

    return [resultsDictionary objectForKey:@"result"];
}

+ (id) QM_aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate 
{
    return [self QM_aggregateOperation:function 
                           onAttribute:attributeName 
                         withPredicate:predicate
                             inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSArray *) QM_aggregateOperation:(NSString *)collectionOperator onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate groupBy:(NSString *)groupingKeyPath inContext:(NSManagedObjectContext *)context;
{
    NSExpression *expression = [NSExpression expressionForFunction:collectionOperator arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:attributeName]]];

    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];

    [expressionDescription setName:@"result"];
    [expressionDescription setExpression:expression];

    NSAttributeDescription *attributeDescription = [[[self QM_entityDescriptionInContext:context] attributesByName] objectForKey:attributeName];
    [expressionDescription setExpressionResultType:[attributeDescription attributeType]];
    NSArray *properties = [NSArray arrayWithObjects:groupingKeyPath, expressionDescription, nil];

    NSFetchRequest *fetchRequest = [self QM_requestAllWithPredicate:predicate];
    [fetchRequest setPropertiesToFetch:properties];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:groupingKeyPath]];

    NSArray *results = [self QM_executeFetchRequest:fetchRequest inContext:context];

    return results;
}

+ (NSArray *) QM_aggregateOperation:(NSString *)collectionOperator onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate groupBy:(NSString *)groupingKeyPath;
{
    return [self QM_aggregateOperation:collectionOperator
                           onAttribute:attributeName
                         withPredicate:predicate groupBy:groupingKeyPath
                             inContext:[[QMCDRecordStack defaultStack] context]];
}

@end
