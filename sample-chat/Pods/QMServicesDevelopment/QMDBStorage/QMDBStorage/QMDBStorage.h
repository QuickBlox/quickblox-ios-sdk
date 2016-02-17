//
//  QMDBStorage.h
//  QMDBStorage
//
//  Created by Andrey Ivanov on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONTAINS(attrName, attrVal) [NSPredicate predicateWithFormat:@"self.%K CONTAINS %@", attrName, attrVal]
#define LIKE(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K like %@", attrName, attrVal]
#define LIKE_C(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K like[c] %@", attrName, attrVal]
#define IS(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K == %@", attrName, attrVal]

#define START_LOG_TIME double startTime = CFAbsoluteTimeGetCurrent();
#define END_LOG_TIME NSLog(@"%s %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent()-startTime);

#define DO_AT_MAIN(x) dispatch_async(dispatch_get_main_queue(), ^{ x; });

#import "QMCDRecord.h"

@interface QMDBStorage : NSObject

@property (strong, nonatomic, readonly) dispatch_queue_t queue;
@property (strong, nonatomic, readonly) QMCDRecordStack *stack;


- (instancetype)initWithStoreNamed:(NSString *)storeName
                             model:(NSManagedObjectModel *)model
                        queueLabel:(const char *)queueLabel;
/**
 * @brief Load CoreData(Sqlite) file
 * @param name - filename
 */

+ (void)setupDBWithStoreNamed:(NSString *)storeName;

/**
 * @brief Clean data base with store name
 */

+ (void)cleanDBWithStoreName:(NSString *)name;

/**
 * @brief Perform operation in CoreData thread
 */

- (void)async:(void(^)(NSManagedObjectContext *context))block;
- (void)sync:(void(^)(NSManagedObjectContext *context))block;

/**
 * @brief Save to persistent store (async)
 */

- (void)save:(dispatch_block_t)completion;

@end