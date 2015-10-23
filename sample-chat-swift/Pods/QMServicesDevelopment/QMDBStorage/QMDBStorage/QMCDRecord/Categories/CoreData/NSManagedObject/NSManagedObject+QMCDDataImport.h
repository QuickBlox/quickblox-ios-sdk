//
//  NSManagedObject+QMCDDataImport.h
//
//  Created by Injoit on 6/28/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString * const kQMCDRecordImportCustomDateFormatKey;
extern NSString * const kQMCDRecordImportDefaultDateFormatString;
extern NSString * const kQMCDRecordImportUnixTimeString;
extern NSString * const kQMCDRecordImportAttributeKeyMapKey;
extern NSString * const kQMCDRecordImportDistinctAttributeKey;
extern NSString * const kQMCDRecordImportAttributeValueClassNameKey;

extern NSString * const kQMCDRecordImportRelationshipMapKey;
extern NSString * const kQMCDRecordImportRelationshipLinkedByKey;
extern NSString * const kQMCDRecordImportRelationshipTypeKey;

extern NSString * const kQMCDRecordImportAttributeUseDefaultValueWhenNotPresent;

@protocol QMCDRecordDataImportProtocol <NSObject>

@optional
- (BOOL) shouldImport:(id)data;
- (void) willImport:(id)data;
- (void) didImport:(id)data;

@end

@interface NSManagedObject (QMCDRecordDataImport) <QMCDRecordDataImportProtocol>

+ (id) QM_importFromObject:(id)data;
+ (id) QM_importFromObject:(id)data inContext:(NSManagedObjectContext *)context;

+ (NSArray *) QM_importFromArray:(id<NSFastEnumeration>)listOfObjectData;
+ (NSArray *) QM_importFromArray:(id<NSFastEnumeration>)listOfObjectData inContext:(NSManagedObjectContext *)context;

@end

