//
//  IosJsInterface.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/29/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol IosJs <JSExport>

- (void)showCollections;
- (void)purchasePack:(NSString *)packTitle :(NSString *)packName :(NSString *)packPrice;
- (void)setInProgress:(BOOL)show;
- (void)removePack:(NSString *)packName;
- (void)showPack:(NSString *)packName;

@end

@protocol STKStickersShopJsInterfaceDelegate <NSObject>

@required
- (void)showCollectionsView;
- (void)purchasePack:(NSString *)packTitle withName:(NSString *)packName
            andPrice:(NSString *)packPrice;
- (void)setInProgress:(BOOL)show;
- (void)showPack:(NSString *)packName;

@optional

- (void)removePack:(NSString *)packName;

@end

@interface STKStickersShopJsInterface : NSObject <IosJs>

@property (nonatomic, strong) id <STKStickersShopJsInterfaceDelegate> delegate;



@end
