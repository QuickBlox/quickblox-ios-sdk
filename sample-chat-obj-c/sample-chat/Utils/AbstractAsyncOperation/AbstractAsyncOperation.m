//
//  AbstractAsyncOperation.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AbstractAsyncOperation.h"
#import "Log.h"

static inline NSString *KeyPathForState(AsyncOperationState state) {
    
    switch (state) {
        case AsyncOperationStateStateReady:        return @"isReady";
        case AsyncOperationStateStateExecuting:    return @"isExecuting";
        case AsyncOperationStateStateFinished:     return @"isFinished";
        case AsyncOperationStateStateCancelled:    return @"isCancelled";
    }
}

@interface AbstractAsyncOperation()
@property (nonatomic, copy) NSString *operationID;
@property(nonatomic, strong, readonly) dispatch_queue_t dispatchQueue;

@end

@implementation AbstractAsyncOperation

//MARK: - Life Cycle
+ (instancetype)asyncOperationWithID:(NSString *)operationID {
    
    AbstractAsyncOperation *operation = [AbstractAsyncOperation operation];
    
    if (operationID.length != 0) {
        operation.operationID = operationID;
    }
    
    return operation;
}

+ (instancetype)operation {
    return [[self alloc] init];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        const char *identifier = "AsyncOperationSerialQueue";
        _dispatchQueue = dispatch_queue_create(identifier, DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_dispatchQueue, (__bridge const void *)(_dispatchQueue),
                                    (__bridge void *)(self), NULL);
    }
    
    return self;
}

- (void)dealloc {
        Log(@"%@, class: %@, id: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class), _operationID);
}

- (NSString *)description {
    
    NSMutableString *result = [NSMutableString stringWithString:[super description]];
    [result appendFormat:@" ->>> %@", _operationID];
    [result appendFormat:@":state = %@", KeyPathForState(_state)];
    
    return result.copy;
}


//MARK - Setup
- (void)setState:(AsyncOperationState)state {
    
    [self performBlockAndWait:^{
        
        if ([self isExecuting]) {
            [self willChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
            self->_state = state;
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
        }
        else {
            [self willChangeValueForKey:@"isExecuting"];
            self->_state = state;
            [self didChangeValueForKey:@"isExecuting"];
        }
    }];
}

//MARK: - Control
- (BOOL)isReady {
    return [super isReady] && self.state == AsyncOperationStateStateReady;
}

- (BOOL)isExecuting {
    return self.state == AsyncOperationStateStateExecuting;
}

- (BOOL)isCancelled {
    return self.state == AsyncOperationStateStateCancelled;
}

- (BOOL)isFinished {
    return self.state == AsyncOperationStateStateFinished;
}

- (void)start {
    @autoreleasepool {
        if (self.isCancelled) {
            self.state = AsyncOperationStateStateFinished;
            return;
        }
        
        [self main];
        self.state = AsyncOperationStateStateExecuting;
    }
}

- (void)cancel {
    [super cancel];
    self.state = AsyncOperationStateStateFinished;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)performBlockAndWait:(dispatch_block_t)block {
    
    void *context = dispatch_get_specific((__bridge const void *)(self.dispatchQueue));
    BOOL runningInDispatchQueue = context == (__bridge void *)(self);
    
    if (runningInDispatchQueue) {
        block();
    } else {
        dispatch_sync(self.dispatchQueue, block);
    }
}

@end
