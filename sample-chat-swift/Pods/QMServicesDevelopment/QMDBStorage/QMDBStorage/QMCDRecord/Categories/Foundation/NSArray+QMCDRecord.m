//
//  Created by Tony Arnold on 8/04/2014. Originally proposed by Raymond Edwards on 09/07/2013
//  Copyright (c) 2014 QMCD Panda Software LLC. All rights reserved.
//

#import "NSArray+QMCDRecord.h"
#import "QMCDRecordStack.h"
#import "NSManagedObject+QMCDRecord.h"

@implementation NSArray (QMCDRecord)

- (NSArray *) QM_entitiesInContext:(NSManagedObjectContext *)context
{
    NSMutableArray *objectsInContext = [NSMutableArray new];

    for (id object in self)
    {
        NSAssert([object isKindOfClass:[NSManagedObject class]], @"Expected NSManagedObject or subclass in array, received %@", NSStringFromClass([object class]));

        NSManagedObject *managedObjectInContext = [object QM_inContext:context];

        if ([managedObjectInContext isKindOfClass:[NSManagedObject class]]) {
            [objectsInContext addObject:managedObjectInContext];
        }
    }

    return objectsInContext;
}

- (void) QM_deleteEntities
{
    [self QM_deleteEntitiesInContext:[[QMCDRecordStack defaultStack] context]];
}

- (void) QM_deleteEntitiesInContext:(NSManagedObjectContext *)otherContext
{
    for (id object in self)
    {
        NSAssert([object isKindOfClass:[NSManagedObject class]], @"Expected NSManagedObject or subclass in array, received %@", NSStringFromClass([object class]));

        [object QM_deleteInContext:otherContext];
    }
}

@end
