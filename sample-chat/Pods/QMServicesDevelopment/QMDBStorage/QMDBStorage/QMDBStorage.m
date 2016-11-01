//
//  QMDBStorage.m
//  QMDBStorage
//
//  Created by Andrey on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMDBStorage.h"

#import "QMSLog.h"

@interface QMDBStorage ()

#define QM_LOGGING_ENABLED 1

@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) QMCDRecordStack *stack;
@property (strong, nonatomic) NSManagedObjectContext *bgContext;

@end

@implementation QMDBStorage

- (instancetype)initWithStoreNamed:(NSString *)storeName model:(NSManagedObjectModel *)model queueLabel:(const char *)queueLabel {
    
    self = [self init];
    if (self) {
        
        self.queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL);
        //Create Chat coredata stack
		self.stack = [AutoMigratingQMCDRecordStack stackWithStoreNamed:storeName model:model];
		[QMCDRecordStack setDefaultStack:self.stack];
    }
    
    return self;
}

+ (void)setupDBWithStoreNamed:(NSString *)storeName {
    
    NSAssert(nil, @"must be overloaded");
}

+ (void)cleanDBWithStoreName:(NSString *)name {
    
    NSURL *storeUrl = [NSPersistentStore QM_fileURLForStoreName:name];
    
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

- (NSManagedObjectContext *)bgContext {
    
    if (!_bgContext) {
        _bgContext = [NSManagedObjectContext QM_confinementContextWithParent:self.stack.context];
    }
    
    return _bgContext;
}

- (void)async:(void(^)(NSManagedObjectContext *context))block {
    
    dispatch_async(self.queue, ^{
        block(self.bgContext);
    });
}

- (void)sync:(void(^)(NSManagedObjectContext *context))block {
    
    dispatch_sync(self.queue, ^{
        block(self.bgContext);
    });
}

- (void)save:(dispatch_block_t)completion {
    
    [self async:^(NSManagedObjectContext *context) {
        
        [context QM_saveToPersistentStoreAndWait];
        
        if (completion) {
            DO_AT_MAIN(completion());
        }
    }];
}

@end
