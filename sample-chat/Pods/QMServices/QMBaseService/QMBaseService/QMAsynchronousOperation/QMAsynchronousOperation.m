//
//  QMAsynchronousOperation.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/23/17.
//
//

#import "QMAsynchronousOperation.h"
#import "QMSLog.h"

typedef NS_ENUM(NSInteger, QMAsynchronousOperationState) {
    QMAsynchronousOperationStateStateReady,
    QMAsynchronousOperationStateStateExecuting,
    QMAsynchronousOperationStateStateFinished,
    QMAsynchronousOperationStateStateCancelled
};

static inline NSString *QMKeyPathForState(QMAsynchronousOperationState state) {
    
    switch (state) {
        case QMAsynchronousOperationStateStateReady:        return @"isReady";
        case QMAsynchronousOperationStateStateExecuting:    return @"isExecuting";
        case QMAsynchronousOperationStateStateFinished:     return @"isFinished";
        case QMAsynchronousOperationStateStateCancelled:    return @"isCancelled";
    }
}

@interface QMAsynchronousOperation()

@property(nonatomic, assign) QMAsynchronousOperationState state;
@property(nonatomic, strong, readonly) dispatch_queue_t dispatchQueue;

@end


@implementation QMAsynchronousOperation

//MARK: - Class methods

+ (instancetype)asynchronousOperationWithID:(NSString *)operationID {
    
    QMAsynchronousOperation *operation = [QMAsynchronousOperation operation];
    
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
        const char *identifier = "QMAsyncOperationSerialQueue";
        _dispatchQueue = dispatch_queue_create(identifier, DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_dispatchQueue, (__bridge const void *)(_dispatchQueue),
                                    (__bridge void *)(self), NULL);
    }
    
    return self;
}

//MARK: - Control

- (BOOL)isExecuting {
    
    __block BOOL isExecuting = NO;
    [self performBlockAndWait:^{
        isExecuting = self.state == QMAsynchronousOperationStateStateExecuting;
    }];
    
    return isExecuting;
}

- (BOOL)isCancelled {
    
    __block BOOL isCancelled = NO;
    [self performBlockAndWait:^{
        isCancelled = self.state == QMAsynchronousOperationStateStateCancelled;
    }];
    
    return isCancelled;
}

- (BOOL)isFinished {
    
    __block BOOL isFinished = NO;
    [self performBlockAndWait:^{
        isFinished =
        self.state == QMAsynchronousOperationStateStateFinished ||
        self.state == QMAsynchronousOperationStateStateCancelled;
    }];
    
    return isFinished;
}

- (void)start {
    @autoreleasepool {
        
        if (self.isCancelled) {
            [self finish];
            return;
        }
        
        __block BOOL isExecuting = YES;
        [self performBlockAndWait:^{
            // Ignore this call if the operation is already executing or if has finished already
            if (self.state != QMAsynchronousOperationStateStateReady) {
                isExecuting = NO;
            }
            else {
                // Signal the beginning of operation
                self.state = QMAsynchronousOperationStateStateExecuting;
            }
        }];
        
        if (isExecuting) {
            // Execute async task
            [self asyncTask];
        }
    }
}

- (void)setCancelBlock:(QMCancellBlock)cancelBlock {
    
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil;
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    
    self.state = QMAsynchronousOperationStateStateCancelled;
    
    if (self.objectToCancel) {
        [self.objectToCancel cancel];
    }
    
    if (_cancelBlock) {
        _cancelBlock();
        _cancelBlock = nil;
    }
}

- (void)setState:(QMAsynchronousOperationState)state {
    
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

//MARK: - NSOperation methods

- (void)asyncTask {
    NSAssert(NO, @"Should be ovverided by subclass");
}

- (void)finish {
    
    [self performBlockAndWait:^{
        // Signal the completion of operation
        if (self.state != QMAsynchronousOperationStateStateFinished) {
            self.state = QMAsynchronousOperationStateStateFinished;
        }
    }];
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

- (void)dealloc {
    QMSLog(@"%@, class: %@, id: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class), _operationID);
}

- (NSString *)description {
    
    NSMutableString *result = [NSMutableString stringWithString:[super description]];
    [result appendFormat:@" ->>> %@", _operationID];
    [result appendFormat:@":state = %@", QMKeyPathForState(_state)];
    
    return result.copy;
}

@end

@implementation QMAsynchronousBlockOperation

- (void)finish {
    
    _asyncOperationBlock = nil;
    [super finish];
}

+ (instancetype)asynchronousOperationWithID:(NSString *)operationID {
    QMAsynchronousBlockOperation *operation = [QMAsynchronousBlockOperation operation];
    
    if (operationID.length != 0) {
        operation.operationID = operationID;
    }

    return operation;
}

- (void)asyncTask {
    
    NSParameterAssert(self.asyncOperationBlock != nil);
    // Invoke execution block
    __weak typeof(self)weakSelf = self;
    self.asyncOperationBlock(^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finish];
    });
}

@end

@implementation NSOperationQueue(QMAsynchronousOperation)

- (void)cancelOperationWithID:(NSString *)operationID {
    [[self operationWithID:operationID] cancel];
}

- (nullable QMAsynchronousOperation *)operationWithID:(NSString *)operationID {
    
    QMAsynchronousOperation *operation = nil;
    for (QMAsynchronousOperation *op in [self operations]) {
        if ([op.operationID isEqualToString:operationID]) {
            operation = op;
            break;
        }
    }
    return operation;
}

- (BOOL)hasOperationWithID:(NSString *)operationID {
    
    QMAsynchronousOperation *operation = [self operationWithID:operationID];
    return operation ? !operation.isCancelled : NO;
}

@end
