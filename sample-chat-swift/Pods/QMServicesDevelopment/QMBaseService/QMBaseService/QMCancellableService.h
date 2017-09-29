//
//  QMCancellable.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 6/27/17.
//

#import <Foundation/Foundation.h>

@protocol QMCancellableService <NSObject>

- (void)cancelOperationWithID:(NSString *)operationID;
- (void)cancelAllOperations;

@end
