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

#define cd_dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

NS_ASSUME_NONNULL_BEGIN

@interface QMDBStorage : NSObject

@property (strong, nonatomic) QMCDRecordStack *stack;

- (instancetype)initWithStoreNamed:(NSString *)storeName
                             model:(NSManagedObjectModel *)model
        applicationGroupIdentifier:(nullable NSString *)appGroupIdentifier;

/**
 * @brief Load CoreData(Sqlite) file
 * @param name - filename
 */
+ (void)setupDBWithStoreNamed:(NSString *)storeName;

+ (void)setupDBWithStoreNamed:(NSString *)storeName
   applicationGroupIdentifier:(nullable NSString *)appGroupIdentifier;

/**
 * @brief Clean data base with store name
 */
+ (void)cleanDBWithStoreName:(NSString *)name;

- (void)performBackgroundQueue:(void (^)(NSManagedObjectContext *ctx))block;
- (void)performMainQueue:(void (^)(NSManagedObjectContext *ctx))block;
- (void)save:(void (^)(NSManagedObjectContext *ctx))block
      finish:(dispatch_block_t)finish;

@end

NS_ASSUME_NONNULL_END
