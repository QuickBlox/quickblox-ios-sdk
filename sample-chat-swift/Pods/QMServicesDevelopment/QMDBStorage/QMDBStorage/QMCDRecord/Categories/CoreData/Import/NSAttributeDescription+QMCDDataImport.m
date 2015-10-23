//
//  NSAttributeDescription+QMCDDataImport.m
//  QMCD Record
//
//  Created by Injoit on 9/4/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSAttributeDescription+QMCDDataImport.h"
#import "NSManagedObject+QMCDDataImport.h"
#import "NSString+QMCDDataImport.h"
#import "NSNumber+QMCDDataImport.h"
#import "QMCDImportFunctions.h"

@implementation NSAttributeDescription (QMCDRecordDataImport)

- (NSString *) QM_primaryKey;
{
    return nil;
}

- (id) QM_colorValueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    return MRColorFromString(value);
}

- (NSDate *) QM_dateValueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    if (![value isKindOfClass:[NSDate class]])
    {
        NSDate *convertedValue = nil;
        NSString *dateFormat;
        NSUInteger index = 0;
        do {
            NSString *dateFormatKey = kQMCDRecordImportCustomDateFormatKey;
            if (index)
            {
                dateFormatKey = [dateFormatKey stringByAppendingFormat:@".%tu", index];
            }
            index++;
            dateFormat = [[self userInfo] valueForKey:dateFormatKey];

            convertedValue = [value QM_dateWithFormat:dateFormat];

        } while (!convertedValue && dateFormat);
        value = convertedValue;
    }
    return value;
}

- (NSNumber *) QM_numberValueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    if (![value isKindOfClass:[NSNumber class]])
    {
        value = MRNumberFromString([value description]);
    }
    return value;
}

- (NSNumber *) QM_booleanValueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    return @([value boolValue]);
}

- (NSString *) QM_stringValueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    return [value description];
}

- (BOOL) QM_isNumericAttributeType;
{
    NSAttributeType attributeType = [self attributeType];
    return
    attributeType == NSInteger16AttributeType ||
    attributeType == NSInteger32AttributeType ||
    attributeType == NSInteger64AttributeType ||
    attributeType == NSDecimalAttributeType ||
    attributeType == NSDoubleAttributeType ||
    attributeType == NSFloatAttributeType;
}

- (BOOL) QM_isStringAttributeType;
{
    NSAttributeType attributeType = [self attributeType];
    return attributeType == NSStringAttributeType;
}

- (BOOL) QM_isDateAttributeType;
{
    NSAttributeType attributeType = [self attributeType];
    return attributeType == NSDateAttributeType;
}

- (BOOL) QM_isBooleanAttributeType;
{
    NSAttributeType attributeType = [self attributeType];
    return attributeType == NSBooleanAttributeType;
}

- (BOOL) QM_isColorAttributeType;
{
    BOOL isColorAttributeType = NO;
    NSString *desiredAttributeType = [[self userInfo] valueForKey:kQMCDRecordImportAttributeValueClassNameKey];
    if (desiredAttributeType)
    {
        isColorAttributeType = [desiredAttributeType hasSuffix:@"Color"];
    }
    return isColorAttributeType;
}

- (id) QM_valueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;
{
    id value = [objectData valueForKeyPath:keyPath];
    if ([value isEqual:[NSNull null]])
    {
        value = nil;
    }
    else if ([self QM_isColorAttributeType])
    {
        value = [self QM_colorValueForKeyPath:keyPath fromObjectData:objectData];
    }
    else if ([self QM_isDateAttributeType])
    {
        value = [self QM_dateValueForKeyPath:keyPath fromObjectData:objectData];
    }
    else if ([self QM_isNumericAttributeType])
    {
        value = [self QM_numberValueForKeyPath:keyPath fromObjectData:objectData];
    }
    else if ([self QM_isStringAttributeType])
    {
        value = [self QM_stringValueForKeyPath:keyPath fromObjectData:objectData];
    }
    else if ([self QM_isBooleanAttributeType])
    {
        value = [self QM_booleanValueForKeyPath:keyPath fromObjectData:objectData];
    }

    return value;   
}

- (BOOL) QM_shouldUseDefaultValueIfNoValuePresent;
{
    return [[[self userInfo] objectForKey:kQMCDRecordImportAttributeUseDefaultValueWhenNotPresent] boolValue];
}

@end

