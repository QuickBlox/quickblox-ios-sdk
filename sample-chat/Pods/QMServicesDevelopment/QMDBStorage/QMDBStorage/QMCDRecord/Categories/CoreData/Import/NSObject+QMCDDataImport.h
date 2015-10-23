//
//  NSDictionary+QMCDDataImport.h
//  QMCD Record
//
//  Created by Injoit on 9/4/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

@interface NSObject (QMCDRecordDataImport)

- (NSString *) QM_lookupKeyForProperty:(NSPropertyDescription *)propertyDescription;
- (id) QM_valueForAttribute:(NSAttributeDescription *)attributeInfo;

- (NSString *) QM_lookupKeyForRelationship:(NSRelationshipDescription *)relationshipInfo;
- (id) QM_relatedValueForRelationship:(NSRelationshipDescription *)relationshipInfo;

@end
