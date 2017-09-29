//
//  QMAsynchronousOperation.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/23/17.
//
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef  void(^QMAsyncOperationBlock)(dispatch_block_t finish);
typedef  void(^QMCancellBlock)(void);

@protocol QMCancellableObject <NSObject>
@required
- (void)cancel;
@end

@interface QMAsynchronousOperation : NSOperation

@property (nonatomic, copy, nullable) NSString *operationID;

@property (nonatomic, copy, nullable) QMAsyncOperationBlock asyncOperationBlock;
@property (nonatomic, copy, nullable) QMCancellBlock cancelBlock;

@property (nonatomic, strong, nullable) id <QMCancellableObject> objectToCancel;

- (void)finish;

+ (instancetype)asynchronousOperationWithID:(NSString *)operationID;

@end


@interface NSOperationQueue(QMAsynchronousOperation)

- (nullable QMAsynchronousOperation *)operationWithID:(NSString *)operationID;

- (BOOL)hasOperationWithID:(NSString *)operationID;

- (void)cancelOperationWithID:(NSString *)operationID;

@end

NS_ASSUME_NONNULL_END
