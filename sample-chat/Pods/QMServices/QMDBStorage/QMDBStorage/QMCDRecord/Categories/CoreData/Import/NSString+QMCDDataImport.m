//
//  NSString+QMCDRecord_QMCDDataImport.m
//  QMCD Record
//
//  Created by Injoit on 12/10/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSString+QMCDDataImport.h"
#import "NSManagedObject+QMCDRecord.h"
#import "QMCDImportFunctions.h"

@implementation NSString (QMCDRecordDataImport)

- (NSString *) QM_capitalizedFirstCharacterString;
{
    if ([self length] > 0)
    {
        NSString *firstChar = [[self substringToIndex:1] capitalizedString];
        return [firstChar stringByAppendingString:[self substringFromIndex:1]];
    }
    return self;
}

- (id) QM_relatedValueForRelationship:(NSRelationshipDescription *)relationshipInfo
{
    return self;
}

- (NSString *) QM_lookupKeyForProperty:(NSPropertyDescription *)propertyDescription
{
    return nil;
}

- (NSDate *)QM_dateWithFormat:(NSString *)dateFormat;
{
    return MRDateFromString(self, dateFormat ?: kQMCDRecordImportDefaultDateFormatString);
}

@end

