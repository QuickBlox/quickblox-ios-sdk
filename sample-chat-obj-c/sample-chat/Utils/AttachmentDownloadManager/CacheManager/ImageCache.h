//
//  ImageCache.h
//  sample-chat
//
//  Created by Injoit on 28.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCache : NSObject
@property (strong, nonatomic) NSString *cachesDirectory;
+ (instancetype)instance;
- (UIImage *)imageFromCacheForKey:(NSString *)key;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;
- (void)removeImageForKey:(NSString *)key;
- (void)removeAllImages;
- (void)getFileWithStringUrl:(NSString *)stringUrl completionHandler: (void(^)(NSURL * _Nullable url, NSError * _Nullable error))completion;
- (void)clearCache;
@end

NS_ASSUME_NONNULL_END
