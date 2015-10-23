//
//  SQLiteQMCDRecordStack.h
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"

@interface SQLiteQMCDRecordStack : QMCDRecordStack

/*!
 @property shouldDeletePersistentStoreOnModelMistmatch
 @abstract If true, when configuring the persistant store coordinator, and QMCD Record encounters a store that does not match the model, it will attempt to remove it and re-create a new store.
 This is extremely useful during development where every model change could potentially require a delete/reinstall of the app.
 */

@property (nonatomic, assign) BOOL shouldDeletePersistentStoreOnModelMismatch;

@property (nonatomic, copy, readwrite) NSDictionary *storeOptions;
@property (nonatomic, copy, readonly) NSURL *storeURL;

+ (instancetype) stackWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model;
+ (instancetype) stackWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model;
+ (instancetype) stackWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model;

+ (instancetype) stackWithStoreNamed:(NSString *)name;
+ (instancetype) stackWithStoreAtURL:(NSURL *)url;
+ (instancetype) stackWithStoreAtPath:(NSString *)path;

- (instancetype) initWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model;
- (instancetype) initWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model;
- (instancetype) initWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model;

- (instancetype) initWithStoreNamed:(NSString *)name;
- (instancetype) initWithStoreAtURL:(NSURL *)url;
- (instancetype) initWithStoreAtPath:(NSString *)path;

- (NSDictionary *) defaultStoreOptions;

@end
