//
//  NSPersistentStoreCoordinator+QMCDRecord.h
//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "NSPersistentStore+QMCDRecord.h"

extern NSString * const QMCDRecordShouldDeletePersistentStoreOnModelMismatchKey;

@interface NSPersistentStoreCoordinator (QMCDRecord)

+ (NSPersistentStoreCoordinator *) QM_newPersistentStoreCoordinator NS_RETURNS_RETAINED;

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore andModel:(NSManagedObjectModel *)model;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithPersistentStore:(NSPersistentStore *)persistentStore andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreNamed:(NSString *)storeFileName;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreNamed:(NSString *)storeFileName withOptions:(NSDictionary *)options;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreNamed:(NSString *)storeFileName andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;

+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreAtURL:(NSURL *)url;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreAtURL:(NSURL *)url andModel:(NSManagedObjectModel *)model;
+ (NSPersistentStoreCoordinator *) QM_coordinatorWithSqliteStoreAtURL:(NSURL *)url andModel:(NSManagedObjectModel *)model withOptions:(NSDictionary *)options;

- (NSPersistentStore *) QM_addSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *__autoreleasing)options;
- (NSPersistentStore *) QM_addSqliteStoreNamed:(id)storeFileName withOptions:(__autoreleasing NSDictionary *)options;

@end
