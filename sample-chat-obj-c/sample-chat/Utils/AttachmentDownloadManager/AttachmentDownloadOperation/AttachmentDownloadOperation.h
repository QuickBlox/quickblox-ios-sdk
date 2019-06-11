//
//  AttachmentDownloadOperation.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractAsyncOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef  void(^ErrorHandler)(NSError *error, NSString *ID);
typedef  void(^SuccessHandler)(UIImage *image, NSString *ID);
typedef  void(^ProgressHandler)(CGFloat progress, NSString *ID);

@interface AttachmentDownloadOperation : AbstractAsyncOperation

@property (nonatomic, copy) NSString *attachmentID;
@property (nonatomic, copy, nullable) ErrorHandler errorHandler;
@property (nonatomic, copy, nullable) SuccessHandler successHandler;
@property (nonatomic, copy, nullable) ProgressHandler progressHandler;

- (instancetype)initWithAttachmentID:(NSString *)attachmentID
                     progressHandler:(ProgressHandler)progressHandler
                      successHandler:(SuccessHandler)successHandler
                        errorHandler:(ErrorHandler)errorHandler;

@end

NS_ASSUME_NONNULL_END
