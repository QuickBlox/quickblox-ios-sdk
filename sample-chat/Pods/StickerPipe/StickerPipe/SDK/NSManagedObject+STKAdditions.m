//
//  NSManagedObject+STKAdditions.m
//  StickerFactory
//
//  Created by Vadim Degterev on 01.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "NSManagedObject+STKAdditions.h"
#import "STKUtility.h"

@implementation NSManagedObject (STKAdditions)

#pragma mark - Find

+ (NSArray*)stk_findAllWithSortDescriptor:(NSArray*) sortDescriptors context:(NSManagedObjectContext*) context {
    
    NSFetchRequest *request = [self stk_fetchRequestWithContext:context];
    
    request.sortDescriptors = sortDescriptors;
    
    __block NSArray *objects = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        
        objects = [context executeFetchRequest:request error:&error];
        
        if (error) {
            STKLog(@"Coredata error: %@", error.localizedDescription);
        }
    }];
    
    return objects;
    
}

+ (NSArray *)stk_findWithPredicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray*)sortDescriptors
                           context:(NSManagedObjectContext *)context {
    return [self stk_findWithPredicate:predicate sortDescriptors:sortDescriptors fetchLimit:0 context:context];
}

+ (NSArray *)stk_findWithPredicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray*)sortDescriptors
                        fetchLimit:(NSInteger) fetchLimit
                           context:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self stk_fetchRequestWithContext:context];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    request.fetchLimit = fetchLimit;
    __block NSArray *objects = nil;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        
        objects = [context executeFetchRequest:request error:&error];
        
        if (error) {
            STKLog(@"Coredata error: %@", error.localizedDescription);
        }
    }];
    
    return objects;
}

+ (NSArray *)stk_findAllInContext:(NSManagedObjectContext*) context {
    
    NSFetchRequest *request = [self stk_fetchRequestWithContext:context];
    
    __block NSArray *objects = nil;
    
    [context performBlockAndWait:^{
       
        NSError *error = nil;
        
        objects = [context executeFetchRequest:request error:&error];
        if (error) {
            STKLog(@"Coredata error: %@", error.localizedDescription);
        }
    }];
    
    return objects;
    
}

+ (NSFetchRequest*)stk_fetchRequestWithContext:(NSManagedObjectContext*) context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:[self stk_entityName] inManagedObjectContext:context];
    return request;
}


#pragma mark - Delete

+ (void)stk_deleteAllInContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    request.entity = [NSEntityDescription entityForName:[self stk_entityName] inManagedObjectContext:context];
    
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        STKLog(@"Coredata delete error: %@", error.localizedDescription);
    }
    for (id object in objects) {
        [context deleteObject:object];
    }
    
}

+ (NSString*) stk_entityName {
    NSString *entityName;
    
    if ([self respondsToSelector:@selector(entityName)])
    {
        entityName = [self performSelector:@selector(entityName)];
    }
    
    if ([entityName length] == 0)
    {
        // Remove module prefix from Swift subclasses
        entityName = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    }
    
    return entityName;
}


#pragma mark - Unique

+ (instancetype) stk_objectWithUniqueAttribute:(NSString *) attribute
                                     value:(id)value
                               context:(NSManagedObjectContext*) context {
    __block id object = nil;
    [context performBlockAndWait:^{
        if (value) {
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self stk_entityName]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
            [request setPredicate:predicate];
            NSError *error = nil;
            object = [[context executeFetchRequest:request error:&error] firstObject];
            if (error) {
                STKLog(@"Coredata unique fetching error: %@", error.localizedDescription);
            }
        } else {
            object = nil;
        }
        
        if (!object) {
            object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                   inManagedObjectContext:context];
        }
    }];
    [context performBlockAndWait:^{

    }];

    return object;
}

@end
