//
//  NSManagedObject+QMCDDataImport.m
//
//  Created by Injoit on 6/28/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"
#import "QMCDRecord.h"
#import "NSObject+QMCDDataImport.h"
#import "QMCDRecordLogging.h"

void QM_swapMethodsFromClass(Class c, SEL orig, SEL new);

NSString * const kQMCDRecordImportCustomDateFormatKey            = @"dateFormat";
NSString * const kQMCDRecordImportDefaultDateFormatString        = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
NSString * const kQMCDRecordImportUnixTimeString                 = @"UnixTime";

NSString * const kQMCDRecordImportAttributeKeyMapKey             = @"mappedKeyName";
NSString * const kQMCDRecordImportAttributeValueClassNameKey     = @"attributeValueClassName";

NSString * const kQMCDRecordImportRelationshipMapKey             = @"mappedKeyName";
NSString * const kQMCDRecordImportRelationshipLinkedByKey        = @"relatedByAttribute";
NSString * const kQMCDRecordImportDistinctAttributeKey           = @"distinctAttribute";
NSString * const kQMCDRecordImportRelationshipTypeKey            = @"type";  //this needs to be revisited

NSString * const kQMCDRecordImportAttributeUseDefaultValueWhenNotPresent = @"useDefaultValueWhenNotPresent";

@implementation NSManagedObject (QMCDRecordDataImport)

#pragma mark - Callbacks

- (BOOL) QM_importValue:(id)value forKey:(NSString *)key
{
    NSString *selectorString = [NSString stringWithFormat:@"import%@:", [key QM_capitalizedFirstCharacterString]];
    SEL selector = NSSelectorFromString(selectorString);

    if ([self respondsToSelector:selector])
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        [invocation setTarget:self];
        [invocation setSelector:selector];
        [invocation setArgument:&value atIndex:2];
        [invocation invoke];

        BOOL returnValue = YES;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }

    return NO;
}

- (BOOL) QM_shouldImportData:(id)relatedObjectData forRelationshipNamed:(NSString *)relationshipName;
{
    BOOL shouldImport = YES; // By default, we always import
    SEL shouldImportSelector = NSSelectorFromString([NSString stringWithFormat:@"shouldImport%@:", [relationshipName QM_capitalizedFirstCharacterString]]);
    BOOL implementsShouldImport = [self respondsToSelector:shouldImportSelector];

    if (implementsShouldImport)
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:shouldImportSelector]];
        [invocation setSelector:shouldImportSelector];
        [invocation setArgument:&relatedObjectData atIndex:2];
        [invocation invokeWithTarget:self];

        [invocation getReturnValue:&shouldImport];
    }
    return shouldImport;
}

#pragma mark - Setting Attributes and Relationships

- (void) QM_setObject:(NSManagedObject *)relatedObject forRelationship:(NSRelationshipDescription *)relationshipInfo
{
    NSAssert2(relatedObject != nil, @"Cannot add nil to %@ for attribute %@", NSStringFromClass([self class]), [relationshipInfo name]);    
    NSAssert2([relatedObject entity] == [relationshipInfo destinationEntity], @"related object entity %@ not same as destination entity %@", [relatedObject entity], [relationshipInfo destinationEntity]);
    
    //add related object to set
    NSString *addRelationMessageFormat = @"set%@:";
    id relationshipSource = self;
    if ([relationshipInfo isToMany]) 
    {
        addRelationMessageFormat = @"add%@Object:";
        if ([relationshipInfo respondsToSelector:@selector(isOrdered)] && [relationshipInfo isOrdered])
        {
            //Need to get the ordered set
            NSString *selectorName = [[relationshipInfo name] stringByAppendingString:@"Set"];
            SEL selector = NSSelectorFromString(selectorName);
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation invokeWithTarget:self];
            [invocation getReturnValue:&relationshipSource];

            addRelationMessageFormat = @"addObject:";
        }
    }

    NSString *addRelatedObjectToSetMessage = [NSString stringWithFormat:addRelationMessageFormat, MRAttributeNameFromString([relationshipInfo name])];
 
    SEL selector = NSSelectorFromString(addRelatedObjectToSetMessage);
    
    @try 
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setArgument:&relatedObject atIndex:2];
        [invocation invokeWithTarget:relationshipSource];
    }
    @catch (NSException *exception) 
    {
        QMCDLogError(@"Adding object for relationship failed: %@\n", relationshipInfo);
        QMCDLogError(@"relatedObject.entity %@", [relatedObject entity]);
        QMCDLogError(@"relationshipInfo.destinationEntity %@", [relationshipInfo destinationEntity]);
        QMCDLogError(@"Add Relationship Selector: %@", addRelatedObjectToSetMessage);
        QMCDLogError(@"perform selector error: %@", exception);
    }
}
- (void) QM_setAttribute:(NSAttributeDescription *)attributeInfo withValueFromObject:(id)objectData
{
    NSString *lookupKeyPath = [objectData QM_lookupKeyForProperty:attributeInfo];

    if (lookupKeyPath)
    {
        NSString *attributeName = [attributeInfo name];
        id value = [attributeInfo QM_valueForKeyPath:lookupKeyPath fromObjectData:objectData];
        if (value == nil && [attributeInfo QM_shouldUseDefaultValueIfNoValuePresent])
        {
            value = [attributeInfo defaultValue];
        }

        //        id value = [attributeInfo QM_valueForKeyPath:lookupKeyPath fromObjectData:objectData];
        if (![self QM_importValue:value forKey:attributeName])
        {
            [self setValue:value forKey:attributeName];
        }
    }
    //    else if ([attributeInfo QM_shouldUseDefaultValueIfNoValuePresent])
    //    {
    //        id value = [attributeInfo defaultValue];
    //        if (![self QM_importValue:value forKey:attributeName])
    //        {
    //            [self setValue:value forKey:attributeName];
    //        }
    //    }
}

- (void) QM_setRelationship:(NSRelationshipDescription *)relationshipInfo relatedData:(id)relationshipData setRelationshipBlock:(void (^)(NSRelationshipDescription *, id))setRelationshipBlock
{
    NSString *relationshipName = [relationshipInfo name];

    if ([self QM_importValue:relationshipData forKey:relationshipName]) return; //If custom import was used

    NSString *lookupKey = [[relationshipInfo userInfo] valueForKey:kQMCDRecordImportRelationshipMapKey] ?: relationshipName;
    id relatedObjectData = [relationshipData valueForKeyPath:lookupKey];
    if (relatedObjectData == nil)
    {
        lookupKey = [relationshipData QM_lookupKeyForProperty:relationshipInfo];
        @try
        {
            relatedObjectData = [relationshipData valueForKeyPath:lookupKey];
        }
        @catch (NSException *exception)
        {
            QMCDLogWarn(@"Looking up a key for relationship failed while importing: %@\n", relationshipInfo);
            QMCDLogWarn(@"lookupKey: %@", lookupKey);
            QMCDLogWarn(@"relationshipInfo.destinationEntity %@", relationshipInfo.destinationEntity);
            QMCDLogWarn(@"relationshipData: %@", relationshipData);
            QMCDLogWarn(@"Exception:\n%@: %@", exception.name, exception.reason);
        }
    }
    if (relatedObjectData == nil || [relatedObjectData isEqual:[NSNull null]]) return;

    void (^establishRelationship)(NSRelationshipDescription *, id) = ^(NSRelationshipDescription *blockInfo, id blockData)
    {
        if ([self QM_shouldImportData:relatedObjectData forRelationshipNamed:relationshipName])
        {
            setRelationshipBlock(blockInfo, blockData);
        }
    };
    
    if ([relationshipInfo isToMany] && [relatedObjectData isKindOfClass:[NSArray class]])
    {
        for (id singleRelatedObjectData in relatedObjectData) 
        {
            establishRelationship(relationshipInfo, singleRelatedObjectData);
        }
    }
    else
    {
        establishRelationship(relationshipInfo, relatedObjectData);
    }
}

#pragma mark - Attribute and Relationship traversal

- (void) QM_setAttributes:(NSDictionary *)attributes forKeysWithObject:(id)objectData
{
    for (NSString *attributeName in attributes)
    {
        NSAttributeDescription *attributeInfo = [attributes valueForKey:attributeName];

        [self QM_setAttribute:attributeInfo withValueFromObject:objectData];
    }
}


- (void) QM_setRelationships:(NSDictionary *)relationshipDescriptions forKeysWithObject:(id)relationshipData withBlock:(void(^)(NSRelationshipDescription *,id))setRelationshipBlock
{
    [relationshipDescriptions enumerateKeysAndObjectsUsingBlock:^(id relationshipName, id relationshipDescription, BOOL *stop) {

        [self QM_setRelationship:relationshipDescription
                     relatedData:relationshipData
            setRelationshipBlock:setRelationshipBlock];
    }];
}

#pragma mark - Pre/Post Import Events

- (BOOL) QM_preImport:(id)objectData;
{
    if ([self respondsToSelector:@selector(shouldImport:)])
    {
        BOOL shouldImport = (BOOL)[self shouldImport:objectData];
        if (!shouldImport) 
        {
            return NO;
        }
    }

    if ([self respondsToSelector:@selector(willImport:)])
    {
        [self willImport:objectData];
    }

    return YES;
}

- (BOOL) QM_postImport:(id)objectData;
{
    if ([self respondsToSelector:@selector(didImport:)])
    {
        [self performSelector:@selector(didImport:) withObject:objectData];
    }

    return YES;
}

#pragma mark - Lookup related/existing data and objects

- (NSManagedObject *) QM_lookupObjectForRelationship:(NSRelationshipDescription *)relationshipInfo fromData:(id)singleRelatedObjectData
{
    NSEntityDescription *destinationEntity = [relationshipInfo destinationEntity];
    NSManagedObject *objectForRelationship = nil;

    id relatedValue;

    // if its a primitive class, than handle singleRelatedObjectData as the key for relationship
    if ([singleRelatedObjectData isKindOfClass:[NSString class]] ||
        [singleRelatedObjectData isKindOfClass:[NSNumber class]])
    {
        relatedValue = singleRelatedObjectData;
    }
    else if ([singleRelatedObjectData isKindOfClass:[NSDictionary class]])
	{
		relatedValue = [singleRelatedObjectData QM_relatedValueForRelationship:relationshipInfo];
	}
	else
    {
        relatedValue = singleRelatedObjectData;
    }

    if (relatedValue)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        Class managedObjectClass = NSClassFromString([destinationEntity managedObjectClassName]);
        NSString *primaryKey = [[destinationEntity QM_primaryAttribute] name];
        if ([primaryKey length])
        {
            objectForRelationship = [managedObjectClass QM_findFirstByAttribute:primaryKey
                                                                      withValue:relatedValue
                                                                      inContext:context];
        }
    }

    return objectForRelationship;
}

#pragma mark - Kicking off importing

- (BOOL) QM_importValuesForKeysWithObject:(id)objectData establishRelationshipBlock:(void(^)(NSRelationshipDescription*, id))relationshipBlock;
{
    BOOL didStartimporting = [self QM_preImport:objectData];
    if (!didStartimporting) return NO;

    NSDictionary *attributes = [[self entity] attributesByName];
    [self QM_setAttributes:attributes forKeysWithObject:objectData];

    NSDictionary *relationships = [[self entity] relationshipsByName];
    [self QM_setRelationships:relationships forKeysWithObject:objectData withBlock:relationshipBlock];

    return [self QM_postImport:objectData];
}

- (BOOL) QM_importValuesForKeysWithObject:(id)objectData
{
	__weak typeof(self) weakSelf = self;

    void (^esablishRelationship)(NSRelationshipDescription*,id) =^(NSRelationshipDescription *relationshipInfo, id localObjectData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        //Look up any existing objects
        NSManagedObject *relatedObject = [strongSelf QM_lookupObjectForRelationship:relationshipInfo fromData:localObjectData];

        if (relatedObject == nil)
        {
            //create if none exist
            NSEntityDescription *entityDescription = [relationshipInfo destinationEntity];
            relatedObject = [entityDescription QM_createInstanceInContext:[strongSelf managedObjectContext]];
        }
        //import or update
        [relatedObject QM_importValuesForKeysWithObject:localObjectData];

        [strongSelf QM_setObject:relatedObject forRelationship:relationshipInfo];
	};

    return [self QM_importValuesForKeysWithObject:objectData establishRelationshipBlock:esablishRelationship];
}

#pragma mark - Class level importing

+ (id) QM_importFromObject:(id)objectData inContext:(NSManagedObjectContext *)context;
{
    NSAttributeDescription *primaryAttribute = [[self QM_entityDescriptionInContext:context] QM_primaryAttribute];
    
    id value = [objectData QM_valueForAttribute:primaryAttribute];
    
    NSManagedObject *managedObject = nil;
    
    if (primaryAttribute != nil)
    {
        managedObject = [self QM_findFirstByAttribute:[primaryAttribute name] withValue:value inContext:context];
    }

    if (managedObject == nil)
    {
        managedObject = [self QM_createEntityInContext:context];
    }

    [managedObject QM_importValuesForKeysWithObject:objectData];

    return managedObject;
}

+ (id) QM_importFromObject:(id)objectData
{
    return [self QM_importFromObject:objectData inContext:[[QMCDRecordStack defaultStack] context]];
}

#pragma mark - Import from collections

+ (NSArray *) QM_importFromArray:(id<NSFastEnumeration>)listOfObjectData
{
    return [self QM_importFromArray:listOfObjectData inContext:[[QMCDRecordStack defaultStack] context]];
}

+ (NSArray *) QM_importFromArray:(id<NSFastEnumeration>)listOfObjectData inContext:(NSManagedObjectContext *)context
{
    // See https://gist.github.com/4501089 and https://alpha.app.net/tonymillion/post/2397422
    
    NSMutableArray *objects = [NSMutableArray array];

    for (id obj in listOfObjectData)
    {
        NSManagedObject *importedObject = [self QM_importFromObject:obj inContext:context];
        [objects addObject:importedObject];
    }
    
    return objects;
}

@end
