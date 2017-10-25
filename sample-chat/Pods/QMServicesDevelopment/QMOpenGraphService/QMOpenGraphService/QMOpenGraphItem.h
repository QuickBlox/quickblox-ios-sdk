//
//  QMOpenGraphItem.h
//  QMOpenGraphService
//
//  Created by Andrey Ivanov on 14/06/2017.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMOpenGraphItem : NSObject

@property (nonatomic, copy, nullable) NSString *ID;
@property (nonatomic, copy, nullable) NSString *baseUrl;
@property (nonatomic, copy, nullable) NSString *faviconUrl;
@property (nonatomic, copy, nullable) NSString *siteTitle;
@property (nonatomic, copy, nullable) NSString *siteDescription;
@property (nonatomic, copy, nullable) NSString *imageURL;
@property (nonatomic, assign) NSUInteger imageHeight;
@property (nonatomic, assign) NSUInteger imageWidth;

@end

NS_ASSUME_NONNULL_END
