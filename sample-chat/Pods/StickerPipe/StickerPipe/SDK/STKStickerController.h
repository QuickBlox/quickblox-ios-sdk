//
//  STKStickerController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STKStickerController;

@protocol STKStickerControllerDelegate <NSObject>

- (void) stickerController:(STKStickerController*)stickerController didSelectStickerWithMessage:(NSString*)message;

@end

@interface STKStickerController : NSObject

@property (weak, nonatomic) id<STKStickerControllerDelegate> delegate;

@property (strong, nonatomic, readonly) UIView *stickersView;

@property (assign, nonatomic, readonly) BOOL isStickerViewShowed;

@property (assign, nonatomic) UIColor *headerBackgroundColor;


//Color settings. Default is light gray

- (void) setColorForStickersPlaceholder:(UIColor*) color;

- (void) setColorForStickersHeaderPlaceholderColor:(UIColor*) color;



@end
