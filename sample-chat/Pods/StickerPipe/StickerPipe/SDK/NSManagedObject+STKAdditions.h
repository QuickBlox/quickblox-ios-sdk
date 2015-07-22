//
//  NSManagedObject+STKAdditions.h
//  StickerFactory
//
//  Created by Vadim Degterev on 01.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (STKAdditions)

+ (NSArray*)stk_findAllInContext:(NSManagedObjectContext*)context;

+ (NSArray *)stk_findWithPredicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray*)sortDescriptors
                           context:(NSManagedObjectContext *)context;

+ (NSArray *)stk_findWithPredicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray*)sortDescriptors
                        fetchLimit:(NSInteger) fetchLimit
                           context:(NSManagedObjectContext *)context;

+ (NSArray*)stk_findAllWithSortDescriptor:(NSArray*)sortDescriptors context:(NSManagedObjectContext*)context;


+ (void) stk_deleteAllInContext:(NSManagedObjectContext*)context;

+ (instancetype) stk_objectWithUniqueAttribute:(NSString *) attribute
                                     value:(id)value
                                   context:(NSManagedObjectContext*) context;


@end
