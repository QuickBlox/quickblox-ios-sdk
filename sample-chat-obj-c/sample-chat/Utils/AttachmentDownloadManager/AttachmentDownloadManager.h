//
//  AttachmentDownloadManager.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentDownloadOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef  void(^ErrorHandler)(NSError *error, NSString *ID);
typedef  void(^ProgressHandler)(CGFloat progress, NSString *ID);

@interface AttachmentDownloadManager : NSObject

- (void)downloadAttachmentWithID:(NSString *)ID
 attachmentName:(NSString *)attachmentName
 attachmentType:(AttachmentType)attachmentType
progressHandler:(ProgressHandler)progressHandler
 successHandler:(SuccessHandler)successHandler
   errorHandler:(ErrorHandler)errorHandler;

- (void)slowDownloadAttachmentWithID:(NSString *)ID;

@end

NS_ASSUME_NONNULL_END
