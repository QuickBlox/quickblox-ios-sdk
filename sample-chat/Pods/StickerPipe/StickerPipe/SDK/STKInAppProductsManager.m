//
//  STKBaseSettingsManager.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/17/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKInAppProductsManager.h"

static NSString *priceBProductIdentifier;
static NSString *priceCProductIdentifier;

@implementation STKInAppProductsManager

+ (void)setPriceBproductId:(NSString *)priceBproductId {
   
    priceBProductIdentifier = priceBproductId;
}

+ (NSString *)priceBProductId {

    return priceBProductIdentifier;
}

+ (void)setPriceCproductId:(NSString *)priceCproductId {
    
    priceCProductIdentifier = priceCproductId;
}

+ (NSString *)priceCProductId {
    
    return priceCProductIdentifier;
}

+ (NSString *)productIdWithPackPrice:(NSString *)packPrice {
   
    if ([packPrice isEqualToString:@"B"]) {
        return priceBProductIdentifier;
    } else if ([packPrice isEqualToString:@"C"]) {
        return priceCProductIdentifier;
    }
    return @"";
}

+ (BOOL)hasProductIds {
 
    return priceBProductIdentifier.length > 0 && priceCProductIdentifier.length > 0;
}

+ (NSArray *)productIds {

    return @[priceBProductIdentifier, priceCProductIdentifier];
}

@end
