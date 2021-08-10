//
//  AttachmentDownloadOperation.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractAsyncOperation.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AttachmentType) {
    AttachmentTypeError = 0,
    AttachmentTypeImage,
    AttachmentTypeVideo,
    AttachmentTypeCamera,
    AttachmentTypeFile
};

typedef  void(^ErrorHandler)(NSError *error, NSString *ID);
typedef  void(^SuccessHandler)(UIImage * _Nullable image, NSURL * _Nullable videoUrl, NSString *ID);
typedef  void(^ProgressHandler)(CGFloat progress, NSString *ID);

@interface AttachmentDownloadOperation : AbstractAsyncOperation

@property (nonatomic, copy) NSString *attachmentID;
@property (nonatomic, copy) NSString *attachmentName;
@property (nonatomic, assign) AttachmentType attachmentType;
@property (nonatomic, copy, nullable) ErrorHandler errorHandler;
@property (nonatomic, copy, nullable) SuccessHandler successHandler;
@property (nonatomic, copy, nullable) ProgressHandler progressHandler;

- (instancetype)initWithAttachmentID:(NSString *)attachmentID
                      attachmentName:(NSString *)attachmentName
                      attachmentType:(AttachmentType)attachmentType
                     progressHandler:(ProgressHandler)progressHandler
                      successHandler:(SuccessHandler)successHandler
                        errorHandler:(ErrorHandler)errorHandler;

@end

NS_ASSUME_NONNULL_END
