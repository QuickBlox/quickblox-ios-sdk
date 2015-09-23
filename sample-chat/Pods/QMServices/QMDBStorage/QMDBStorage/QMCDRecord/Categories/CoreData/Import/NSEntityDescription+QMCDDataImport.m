//
//  NSEntityDescription+QMCDDataImport.m
//  QMCD Record
//
//  Created by Injoit on 9/5/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "NSEntityDescription+QMCDDataImport.h"

@implementation NSEntityDescription (QMCDRecordDataImport)

- (NSManagedObject *) QM_createInstanceInContext:(NSManagedObjectContext *)context;
{
    Class relatedClass = NSClassFromString([self managedObjectClassName]);
    NSManagedObject *newInstance = [relatedClass QM_createInContext:context];

    return newInstance;
}

- (NSAttributeDescription *) QM_attributeDescriptionForName:(NSString *)name;
{
    __block NSAttributeDescription *description = nil;

    NSDictionary *attributesByName = [self attributesByName];

    [attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attributeDescription, BOOL *stop) {
        if ([attributeName isEqualToString:name])
        {
            description = attributeDescription;

            *stop = YES;
        }
    }];

    return description;
}

- (NSAttributeDescription *) QM_primaryAttributeToRelateBy;
{
    NSString *lookupKey = [[self userInfo] valueForKey:kQMCDRecordImportRelationshipLinkedByKey] ?: MRPrimaryKeyNameFromString([self name]);

    return [self QM_attributeDescriptionForName:lookupKey];
}

- (NSAttributeDescription *) QM_primaryAttribute;
{
    NSString *lookupKey = [[self userInfo] valueForKey:kQMCDRecordImportDistinctAttributeKey];
    return [self QM_attributeDescriptionForName:lookupKey];
}

@end
