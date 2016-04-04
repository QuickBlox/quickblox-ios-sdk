//
//  SKProduct+STKStickerSKProduct.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/22/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "SKProduct+STKStickerSKProduct.h"

@implementation SKProduct (STKStickerSKProduct)

- (NSString *)currencyString {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:self.priceLocale];
    return [formatter stringFromNumber:self.price];
}
@end
