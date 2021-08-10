//
//  AbstractAsyncOperation.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "AbstractAsyncOperation.h"
#import "Log.h"

static inline NSString *KeyPathForState(AsyncOperationState state) {
    
    switch (state) {
        case AsyncOperationStateReady:        return @"isReady";
        case AsyncOperationStateExecuting:    return @"isExecuting";
        case AsyncOperationStateFinished:     return @"isFinished";
        case AsyncOperationStateCancelled:    return @"isCancelled";
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
    return [super isReady] && self.state == AsyncOperationStateReady;
}

- (BOOL)isExecuting {
    return self.state == AsyncOperationStateExecuting;
}

- (BOOL)isCancelled {
    return self.state == AsyncOperationStateCancelled;
}

- (BOOL)isFinished {
    return self.state == AsyncOperationStateFinished;
}

- (void)start {
    @autoreleasepool {
        if (self.isCancelled) {
            self.state = AsyncOperationStateFinished;
            return;
        }
        
        [self main];
        self.state = AsyncOperationStateExecuting;
    }
}

- (void)cancel {
    [super cancel];
    self.state = AsyncOperationStateFinished;
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
