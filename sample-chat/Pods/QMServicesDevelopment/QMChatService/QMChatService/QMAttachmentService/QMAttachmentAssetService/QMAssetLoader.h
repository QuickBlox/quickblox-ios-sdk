//
//  QMAssetLoader.h
//
//
//  Created by Vitaliy Gurkovsky on 2/26/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QMAssetLoaderCompletionBlock)(NSTimeInterval duration, CGSize size, UIImage * __nullable image, NSError *__nullable error);

typedef NS_ENUM(NSUInteger, QMAssetLoaderStatus) {
    
    QMAssetLoaderStatusNotLoaded = 0,
    QMAssetLoaderStatusLoading,
    QMAssetLoaderStatusFinished,
    QMAssetLoaderStatusFailed,
    QMAssetLoaderStatusCancelled
};

@class QBChatAttachment;

@interface QMAssetLoader : NSObject

@property (assign, nonatomic, readonly) QMAssetLoaderStatus loaderStatus;

+ (instancetype)loaderForAttachment:(QBChatAttachment *)attachment
                          messageID:(NSString *)messageID;
- (void)loadWithTimeOut:(NSTimeInterval)timeOutInterval
        completionBlock:(QMAssetLoaderCompletionBlock)completionBlock;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
