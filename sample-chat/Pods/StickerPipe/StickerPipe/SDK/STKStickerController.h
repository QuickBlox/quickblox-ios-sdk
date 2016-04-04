//
//  STKStickerController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STKStickersConstants.h"

@class STKStickerController;
@class STKShowStickerButton;

@protocol STKStickerControllerDelegate <NSObject>

@required

//View controller for presenting modal controllers
- (UIViewController*)stickerControllerViewControllerForPresentingModalView;

@optional

- (void)stickerController:(STKStickerController*)stickerController didSelectStickerWithMessage:(NSString*)message;

- (void)stickerControllerDidChangePackStatus:(STKStickerController*)stickerController;

- (void)stickerController:(STKStickerController*)stickerController
    willShareStickerWithMessage:(NSString *)message;

@end

@interface STKStickerController : NSObject

@property (weak, nonatomic) id<STKStickerControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *stickersView;

@property (nonatomic, assign, readonly) BOOL isStickerViewShowed;

@property (nonatomic, strong) UIColor *headerBackgroundColor;

@property (nonatomic, strong) UITextView *textInputView;

@property (strong, nonatomic) STKShowStickerButton *keyboardButton;

@property (nonatomic) CGRect stickersViewFrame;

@property (nonatomic) BOOL showStickersOnStart;


//@property (nonatomic, strong) UIColor *stickersShopTintColor;

- (void)updateFrames;

- (void)reloadStickersView;

- (void) showStickersView;

- (void) hideStickersView;

- (BOOL)isStickerPackDownloaded:(NSString*)packMessage;

- (void)showPackInfoControllerWithStickerMessage:(NSString*)message;

//Color settings. Default is light gray

- (void)setColorForStickersPlaceholder:(UIColor*) color;

- (void)setColorForStickersHeaderPlaceholderColor:(UIColor*) color;

- (void)textMessageSent:(NSString *)message;

@end
