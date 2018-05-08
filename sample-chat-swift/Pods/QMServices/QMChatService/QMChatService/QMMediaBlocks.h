//
//  QMMediaBlocks.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/8/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMChatTypes.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^QMAttachmentProgressBlock)(float progress);

typedef void (^QMAttachmentAssetLoaderCompletionBlock)(UIImage * _Nullable image, Float64 durationInSeconds, CGSize size, NSError * _Nullable error, BOOL cancelled);

NS_ASSUME_NONNULL_END

