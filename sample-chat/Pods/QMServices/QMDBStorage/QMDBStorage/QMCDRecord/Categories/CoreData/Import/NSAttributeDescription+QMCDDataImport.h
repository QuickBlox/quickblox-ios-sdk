//
//  NSAttributeDescription+QMCDDataImport.h
//  QMCD Record
//
//  Created by Injoit on 9/4/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

@interface NSAttributeDescription (QMCDRecordDataImport)

- (NSString *) QM_primaryKey;
- (id) QM_valueForKeyPath:(NSString *)keyPath fromObjectData:(id)objectData;

- (BOOL) QM_shouldUseDefaultValueIfNoValuePresent;

@end
