//
//  QMMediaDownloadService.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMediaDownloadServiceDelegate.h"
#import "QMCancellableService.h"
#import "QMMediaBlocks.h"

#import "QMAsynchronousOperation.h"


@interface QMDownloadOperation : QMAsynchronousOperation

@property (nonatomic, strong) QBRequest *request;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSData *data;

@end

@interface QMMediaDownloadService : NSObject <QMCancellableService>

- (BOOL)isDownloadingMessageWithID:(NSString *)messageID;

- (void)downloadAttachmentWithID:(NSString *)attachmentID
                       messageID:(NSString *)messageID
                   progressBlock:(QMAttachmentProgressBlock)progressBlock
                 completionBlock:(void(^)(QMDownloadOperation *downloadOperation))completion;

@end
