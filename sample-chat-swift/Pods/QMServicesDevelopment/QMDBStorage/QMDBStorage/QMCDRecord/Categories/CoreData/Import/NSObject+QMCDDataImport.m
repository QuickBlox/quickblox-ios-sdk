//
//  NSDictionary+QMCDDataImport.m
//  QMCD Record
//
//  Created by Injoit on 9/4/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSObject+QMCDDataImport.h"
#import "QMCDRecord.h"
#import "QMCDRecordLogging.h"

NSUInteger const kQMCDRecordImportMaximumAttributeFailoverDepth = 10;

@implementation NSObject (QMCDRecordDataImport)

- (NSString *) QM_lookupKeyForProperty:(NSPropertyDescription *)propertyDescription;
{
    NSString *attributeName = [propertyDescription name];
    NSDictionary *userInfo = [propertyDescription userInfo];
    NSString *lookupKey = [userInfo valueForKey:kQMCDRecordImportAttributeKeyMapKey] ?: attributeName;
    
    id value = [self valueForKeyPath:lookupKey];
    
    for (NSUInteger i = 1; i < kQMCDRecordImportMaximumAttributeFailoverDepth && value == nil; i++)
    {
        attributeName = [NSString stringWithFormat:@"%@.%tu", kQMCDRecordImportAttributeKeyMapKey, i];
        lookupKey = [userInfo valueForKey:attributeName];
        if (lookupKey == nil) 
        {
            return nil;
        }
        value = [self valueForKeyPath:lookupKey];
    }
    
    return value != nil ? lookupKey : nil;
}

- (id) QM_valueForAttribute:(NSAttributeDescription *)attributeInfo
{
    NSString *lookupKey = [self QM_lookupKeyForProperty:attributeInfo];
    return lookupKey ? [self valueForKeyPath:lookupKey] : nil;
}

- (NSString *) QM_lookupKeyForRelationship:(NSRelationshipDescription *)relationshipInfo
{
    NSEntityDescription *destinationEntity = [relationshipInfo destinationEntity];
    if (destinationEntity == nil) 
    {
        QMCDLogWarn(@"Unable to find entity for type '%@'", [self valueForKey:kQMCDRecordImportRelationshipTypeKey]);
        return nil;
    }
    
    NSAttributeDescription *primaryKeyAttribute = [destinationEntity QM_primaryAttribute];
    NSString *lookupKey = [self QM_lookupKeyForProperty:primaryKeyAttribute] ?: [primaryKeyAttribute name];

    return lookupKey;
}

- (id) QM_relatedValueForRelationship:(NSRelationshipDescription *)relationshipInfo
{
    NSString *lookupKey = [self QM_lookupKeyForRelationship:relationshipInfo];
    return lookupKey ? [self valueForKeyPath:lookupKey] : nil;
}

@end
