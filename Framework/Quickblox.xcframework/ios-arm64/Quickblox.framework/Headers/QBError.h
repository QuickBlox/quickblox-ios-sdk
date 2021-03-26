//
//  QBError.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBError : NSObject

@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *reasons;
@property (nonatomic, readonly, nullable) NSError *error;

+ (instancetype)errorWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
