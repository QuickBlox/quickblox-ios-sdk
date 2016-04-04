//
//  STKStickersPurchaseService.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 2/16/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STKStickersPurchaseDelegate <NSObject>

- (void)purchaseSucceededWithPackName:(NSString *)packName
                        andPackPrice:(NSString *)packPrice;

- (void)purchaseFailedWithError:(NSError *)error;


@end

@interface STKStickersPurchaseService : NSObject

@property (nonatomic, strong) id<STKStickersPurchaseDelegate> delegate;

+ (STKStickersPurchaseService *) sharedInstance;

@property (nonatomic, copy) void(^purchaseFailed)(NSError* error);


- (void)requestProductsWithIdentifier:(NSArray *)productIds
                           completion:(void(^) (NSArray *))completion
                              failure:(void(^)(NSError *error))failre;

- (void)purchaseProductWithPackName:(NSString *)packName
                         andPackPrice:(NSString *)packPrice;

- (void)purchasInternalPackName:(NSString *)packName
                   andPackPrice:(NSString *)packPrice;

- (void)purchaseFailedError:(NSError *)error;
@end
