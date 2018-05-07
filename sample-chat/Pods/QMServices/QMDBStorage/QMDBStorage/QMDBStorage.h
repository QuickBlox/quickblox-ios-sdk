//
//  QMDBStorage.h
//  QMDBStorage
//
//  Created by Andrey Ivanov on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMCDRecord.h"

#define IS(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K == %@", attrName, attrVal]

NS_ASSUME_NONNULL_BEGIN

@interface QMDBStorage : NSObject

@property (strong, nonatomic) QMCDRecordStack *stack;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Init with store name, model and app group identifier

 @param storeName Store name
 @param model model name
 @param appGroupIdentifier App group identifier
 @return instance
 */
- (instancetype)initWithStoreNamed:(NSString *)storeName
                             model:(NSManagedObjectModel *)model
        applicationGroupIdentifier:(nullable NSString *)appGroupIdentifier NS_DESIGNATED_INITIALIZER;

/**
 Setup database
 
 @brief Load CoreData(Sqlite) file
 @param storeName - filename
 */
+ (void)setupDBWithStoreNamed:(NSString *)storeName;

/**
 Setup stack with store name and group identifier

 @param storeName Store name
 @param appGroupIdentifier App group identifier
 */
+ (void)setupDBWithStoreNamed:(NSString *)storeName
   applicationGroupIdentifier:(nullable NSString *)appGroupIdentifier;

/**
 Clean data base with store name
 */
+ (void)cleanDBWithStoreName:(NSString *)name;

/**
 Asynchronously performs a given block on the NSPrivateQueueConcurrencyType queue.
 @param block Background queue context (NSPrivateQueueConcurrencyType)
 */
- (void)performBackgroundQueue:(void (^)(NSManagedObjectContext *ctx))block;

/**
 Synchronously performs a given block on the NSPrivateQueueConcurrencyType queue.
 */
- (void)performMainQueue:(void (^)(NSManagedObjectContext *ctx))block;

/**
 Saves to Persistent Store.
 
 @param block Asynchronously performs a given block on the NSPrivateQueueConcurrencyType queue
 @param finish Asyncronously performs a given block after saveToPersistentStoreAndWait on the main queue
 */
- (void)save:(void (^)(NSManagedObjectContext *ctx))block
      finish:(dispatch_block_t)finish;

@end

NS_ASSUME_NONNULL_END
