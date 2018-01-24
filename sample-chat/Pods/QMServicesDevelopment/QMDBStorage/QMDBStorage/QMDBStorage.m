//
//  QMDBStorage.m
//  QMDBStorage
//
//  Created by Andrey on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMDBStorage.h"

#import "QMSLog.h"
#import "QMCDRecord.h"

@interface QMDBStorage ()

#define QM_LOGGING_ENABLED 1

@end

@implementation QMDBStorage

- (instancetype)initWithStoreNamed:(NSString *)storeName
                             model:(NSManagedObjectModel *)model
        applicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    self = [super init];
    
    if (self) {
        
        _stack = [QMCDRecordStack stackWithStoreNamed:storeName
                                                model:model
                           applicationGroupIdentifier:appGroupIdentifier];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [QMCDRecord setLoggingLevel:QMCDRecordLoggingLevelOff];
        });
    }
    
    return self;
}

- (void)performBackgroundQueue:(void (^)(NSManagedObjectContext *ctx))block {
    NSManagedObjectContext *backgroundContext = [NSManagedObjectContext QM_privateQueueContext];
    [backgroundContext setParentContext:self.stack.privateWriterContext];
    [backgroundContext performBlock:^{
        block(backgroundContext);
    }];
}

- (void)performMainQueue:(void (^)(NSManagedObjectContext *ctx))block {
    
    NSManagedObjectContext *mainContext = [NSManagedObjectContext QM_mainQueueContext];
    [mainContext setParentContext:self.stack.privateWriterContext];
    [mainContext performBlockAndWait:^{
        block(mainContext);
    }];
}

- (void)save:(void (^)(NSManagedObjectContext *ctx))block
      finish:(dispatch_block_t)finish {
    
    NSManagedObjectContext *ctx = self.stack.privateWriterContext;
    
    [ctx performBlock:^{
        
        dispatch_block_t complete = ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (finish) {
                    finish();
                }
            });
        };
        
        block(ctx);
        
        if (!ctx.hasChanges) {
            complete();
            return;
        }
        
        if (ctx.insertedObjects.count > 0) {
            QMSLog(@"[%@] Save: %tu inserted object(s)",
                   NSStringFromClass([self class]),
                   ctx.insertedObjects.count);
        }
        else if (ctx.updatedObjects.count > 0) {
            QMSLog(@"[%@] Save: %tu updated object(s)",
                   NSStringFromClass([self class]),
                   ctx.updatedObjects.count);
        }
        else if (ctx.deletedObjects.count > 0) {
            QMSLog(@"[%@] Save: %tu deleted object(s)",
                   NSStringFromClass([self class]),
                   ctx.deletedObjects.count);
        }
        
        [ctx QM_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            
            if (!success) {
                QMSLog(@"[%@] Save error: %@",
                       NSStringFromClass([self class]),
                       error);
            }
            complete();
        }];
    }];
}

+ (void)setupDBWithStoreNamed:(NSString *)storeName {
    
    NSAssert(nil, @"must be overloaded");
}

+ (void)setupDBWithStoreNamed:(NSString *)storeName
   applicationGroupIdentifier:(nullable NSString *)appGroupIdentifier {
    NSAssert(nil, @"must be overloaded");
}

+ (void)cleanDBWithStoreName:(NSString *)name {
    
    [self cleanDBWithStoreName:name applicationGroupIdentifier:nil];
}

+ (void)cleanDBWithStoreName:(NSString *)name
  applicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    NSURL *storeUrl =
    [NSPersistentStore QM_fileURLForStoreNameIfExistsOnDisk:name
                                 applicationGroupIdentifier:appGroupIdentifier];
    
    if (storeUrl) {
        
        NSError *error = nil;
        if(![[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error]) {
            
            QMSLog(@"An error has occurred while deleting %@", storeUrl);
            QMSLog(@"Error description: %@", error.description);
        }
        else {
            
            QMSLog(@"Clear %@ - Done!", storeUrl);
        }
    }
}

@end
