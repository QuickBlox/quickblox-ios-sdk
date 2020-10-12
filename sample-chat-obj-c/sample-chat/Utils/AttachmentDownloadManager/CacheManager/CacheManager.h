//
//  CacheManager.h
//  samplechat
//
//  Created by Injoit on 06.03.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CacheManager : NSObject
@property (strong, nonatomic) NSString *cachesDirectory;
+ (instancetype)instance;
- (void)getFileWithStringUrl:(NSString *)stringUrl completionHandler: (void(^)(NSURL * _Nullable url, NSError * _Nullable error))completion;
- (void)clearCache;
@end

NS_ASSUME_NONNULL_END
