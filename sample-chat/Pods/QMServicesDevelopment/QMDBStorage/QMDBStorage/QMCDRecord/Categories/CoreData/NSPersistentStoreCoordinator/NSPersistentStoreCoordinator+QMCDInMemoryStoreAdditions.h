//
//  NSPersistentStoreCoordinator+QMCDInMemoryStoreAdditions.h
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (QMCDInMemoryStoreAdditions)

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithInMemoryStore;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithInMemoryStoreWithModel:(NSManagedObjectModel *)model;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithInMemoryStoreWithModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;

- (NSPersistentStore *) QM_addInMemoryStore;
- (NSPersistentStore *) QM_addInMemoryStoreWithOptions:(NSDictionary *)options;

@end
