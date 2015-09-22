//
//  NSRelationshipDescription+QMCDDataImport.m
//  QMCD Record
//
//  Created by Injoit on 9/4/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "NSRelationshipDescription+QMCDDataImport.h"
#import "NSManagedObject+QMCDDataImport.h"
#import "QMCDImportFunctions.h"
#import "QMCDRecord.h"

@implementation NSRelationshipDescription (QMCDRecordDataImport)

- (NSString *) QM_primaryKey;
{
    NSString *primaryKeyName = [[self userInfo] valueForKey:kQMCDRecordImportDistinctAttributeKey] ?: 
    MRPrimaryKeyNameFromString([[self destinationEntity] name]);
    
    return primaryKeyName;
}

@end
