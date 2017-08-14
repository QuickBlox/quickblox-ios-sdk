//
//  QMCDRecordStack.h
//  QMCDRecord
//
//  Created by Injoit on 9/14/13.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface QMCDRecordStack : NSObject

@property (nonatomic, copy) NSString *stackName;

@property (nonatomic, strong, readonly) NSManagedObjectContext *privateWriterContext;

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSPersistentStore *store;


/*!
 @property shouldDeletePersistentStoreOnModelMistmatch
 @abstract If true, when configuring the persistant store coordinator, and QMCD Record encounters a store that does not match the model, it will attempt to remove it and re-create a new store.
 This is extremely useful during development where every model change could potentially require a delete/reinstall of the app.
 */

@property (nonatomic, assign) BOOL shouldDeletePersistentStoreOnModelMismatch;

@property (nonatomic, copy, readwrite) NSDictionary *storeOptions;
@property (nonatomic, copy, readonly) NSURL *storeURL;

@property (nonatomic, assign) BOOL loggingEnabled;
@property (nonatomic, assign) BOOL saveOnApplicationWillTerminate;
@property (nonatomic, assign) BOOL saveOnApplicationWillResignActive;

+ (instancetype)stack;

- (void)reset;

- (void)setModelFromClass:(Class)modelClass;
- (void)setModelNamed:(NSString *)modelName;

+ (instancetype)stackWithStoreNamed:(NSString *)name
                              model:(NSManagedObjectModel *)model;

+ (instancetype)stackWithStoreNamed:(NSString *)name
                              model:(NSManagedObjectModel *)model
         applicationGroupIdentifier:(NSString *)appGroupIdentifier;

- (NSDictionary *)defaultStoreOptions;


@end
