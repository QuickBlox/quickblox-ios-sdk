//
//  NSNumber+QMCDDataImport.m
//  QMCD Record
//
//  Created by Injoit on 9/4/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSNumber+QMCDDataImport.h"
#import "NSManagedObject+QMCDRecord.h"
#import "QMCDImportFunctions.h"

@implementation NSNumber (QMCDRecordDataImport)

- (id) QM_relatedValueForRelationship:(NSRelationshipDescription *)relationshipInfo
{
    return self;
}

- (NSString *) QM_lookupKeyForProperty:(NSPropertyDescription *)propertyDescription
{
    return nil;
}

- (NSDate *) QM_dateWithFormat:(NSString *)dateFormat;
{
    return MRDateFromNumber(self, [dateFormat isEqualToString:kQMCDRecordImportUnixTimeString]);
}

@end
