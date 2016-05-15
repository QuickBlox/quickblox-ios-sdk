//
//  TWMessageBarManager+Private.h
//  sample-chat
//
//  Created by Vitaliy Gurkovsky on 5/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <TWMessageBarManager/TWMessageBarManager.h>

@protocol TWMessageViewDelegate;

@interface TWMessageBarManager (Private)

+ (CGFloat)durationForMessageType:(TWMessageBarMessageType)messageType;

@end

@interface TWMessageView : UIView

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *descriptionString;

@property (nonatomic, assign) TWMessageBarMessageType messageType;

@property (nonatomic, assign) BOOL hasCallback;
@property (nonatomic, strong) NSArray *callbacks;

@property (nonatomic, assign, getter = isHit) BOOL hit;

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, weak) id <TWMessageViewDelegate> delegate;


// Initializers
- (id)initWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type;

// Getters
- (CGFloat)height2;
- (CGFloat)width;
- (CGFloat)statusBarOffset;
- (CGFloat)availableWidth;
- (CGSize)titleSize;
- (CGSize)descriptionSize;
- (CGRect)statusBarFrame;
- (UIFont *)titleFont;
- (UIFont *)descriptionFont;
- (UIColor *)titleColor;
- (UIColor *)descriptionColor;

// Helpers
- (CGRect)orientFrame:(CGRect)frame;

// Notifications
- (void)didChangeDeviceOrientation:(NSNotification *)notification;

@end

@protocol TWMessageViewDelegate <NSObject>

- (NSObject<TWMessageBarStyleSheet> *)styleSheetForMessageView:(TWMessageView *)messageView;

@end
