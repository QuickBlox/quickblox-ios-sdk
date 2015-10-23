//
//  CustomMigratingQMCDRecordStack.h
//  QMCDRecord
//
//  Created by Injoit on 10/11/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "SQLiteQMCDRecordStack.h"

@interface AutoMigratingWithSourceAndTargetModelQMCDRecordStack : SQLiteQMCDRecordStack

- (instancetype) initWithSourceModel:(NSManagedObjectModel *)sourceModel targetModel:(NSManagedObjectModel *)targetModel storeAtURL:(NSURL *)storeURL;
- (instancetype) initWithSourceModel:(NSManagedObjectModel *)sourceModel targetModel:(NSManagedObjectModel *)targetModel storeAtPath:(NSString *)path;
- (instancetype) initWithSourceModel:(NSManagedObjectModel *)sourceModel targetModel:(NSManagedObjectModel *)targetModel storeNamed:(NSString *)storeName;

@end
