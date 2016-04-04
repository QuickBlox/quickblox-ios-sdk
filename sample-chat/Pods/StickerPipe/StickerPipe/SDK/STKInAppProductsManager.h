//
//  STKBaseSettingsManager.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/17/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKInAppProductsManager : NSObject


+ (void)setPriceBproductId:(NSString *)priceBproductId;
+ (NSString *)priceBProductId;

+ (void)setPriceCproductId:(NSString *)priceCproductId;
+ (NSString *)priceCProductId;

+ (NSString *)productIdWithPackPrice:(NSString *)packPrice;

+ (BOOL)hasProductIds;

+ (NSArray *)productIds;

@end
