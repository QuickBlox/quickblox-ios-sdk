//
//  QMAssetLoader.h
//
//
//  Created by Vitaliy Gurkovsky on 2/26/17.
//
//

#import <Foundation/Foundation.h>
#import "QMAsynchronousOperation.h"
#import "QBChatAttachment+QMCustomParameters.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QMAssetLoaderCompletionBlock)(NSTimeInterval duration,
                                            CGSize size,
                                            UIImage * __nullable image,
                                            NSError *__nullable error);

typedef NS_OPTIONS(NSInteger, QMAssetLoaderKeyOptions) {
    QMAssetLoaderKeyTracks = 1 << 0,
    QMAssetLoaderKeyDuration = 1 << 1,
    QMAssetLoaderKeyPlayable = 1 << 2,
    QMAssetLoaderKeyImage = 1 << 3
};


@interface QMAssetOperation : QMAsynchronousOperation


- (instancetype)initWithID:(NSString *)operationID
                       URL:(NSURL *)assetURL
            attachmentType:(QMAttachmentType)type
                   timeOut:(NSTimeInterval)timeInterval
                   options:(QMAssetLoaderKeyOptions)options
           completionBlock:(QMAssetLoaderCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
