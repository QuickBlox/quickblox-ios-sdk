//
//  AbstractAsyncOperation.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AsyncOperationState) {
    AsyncOperationStateReady,
    AsyncOperationStateExecuting,
    AsyncOperationStateFinished,
    AsyncOperationStateCancelled
};

@interface AbstractAsyncOperation : NSOperation

@property(nonatomic, assign) AsyncOperationState state;

@end

NS_ASSUME_NONNULL_END
