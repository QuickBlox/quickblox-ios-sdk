//
//  ButtonsFactory.m
//  sample-conference-videochat
//
//  Created by Injoit on 23/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "ButtonsFactory.h"

const CGRect kDefRect = {0, 0, 56, 76};
const CGRect kDefDeclineRect = {0, 0, 96, 44};
const CGRect kDefCircleDeclineRect = {0, 0, 44, 44};

#define kDefBackgroundColor [UIColor colorWithRed:0.85 green:0.89 blue:0.97 alpha:1.0]
#define kDefSelectedColor [UIColor colorWithRed:0.43 green:0.48 blue:0.58 alpha:1.0]
#define kDefDeclineColor [UIColor colorWithRed:0.94 green:0.20 blue:0.28 alpha:1.0]

@implementation ButtonsFactory

#pragma mark - Private

+ (CustomButton *)buttonWithFrame:(CGRect)frame
            backgroundColor:(UIColor *)backgroundColor
              selectedColor:(UIColor *)selectedColor
              selectedTitle:(NSString *)selectedTitle
            unSelectedTitle:(NSString *)unSelectedTitle {
    
    CustomButton *button = [[CustomButton alloc] initWithFrame:frame];
    button.selectedColor = selectedColor;
    button.unSelectedColor = backgroundColor;
    button.selectedTitle = selectedTitle;
    button.unSelectedTitle = unSelectedTitle;
    
    return button;
}

+ (UIImageView *)iconViewWithNormalImage:(NSString *)normalImage
                           selectedImage:(NSString *)selectedImage {
    
    UIImage *icon = [UIImage imageNamed:normalImage];
    UIImage *selectedIcon = [UIImage imageNamed:selectedImage];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon
                                              highlightedImage:selectedIcon];
    
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    return iconView;
}

#pragma mark - Public

+ (CustomButton *)videoEnable {
    CustomButton *button = [self buttonWithFrame:kDefRect
                           backgroundColor:kDefBackgroundColor
                             selectedColor:kDefSelectedColor selectedTitle:@"Cam on" unSelectedTitle:@"Cam off"];
    button.pushed = YES;
    button.iconView = [self iconViewWithNormalImage:@"camera_on_ic"
                                      selectedImage:@"cam_off"];
    return button;
}

+ (CustomButton *)auidoEnable {
    CustomButton *button = [self buttonWithFrame:kDefRect
                           backgroundColor:kDefBackgroundColor
                             selectedColor:kDefSelectedColor selectedTitle:@"Unmute" unSelectedTitle:@"Mute"];
    button.pushed = YES;
    button.iconView = [self iconViewWithNormalImage:@"mute_on_ic"
                                      selectedImage:@"mic_off"];
    return button;
}

+ (CustomButton *)screenShare {
    CustomButton *button = [self buttonWithFrame:kDefRect
                           backgroundColor:kDefBackgroundColor
                             selectedColor:kDefSelectedColor selectedTitle:@"Stop sharing" unSelectedTitle:@"Screen share"];
    button.iconView = [self iconViewWithNormalImage:@"screensharing_ic"
                                      selectedImage:@"screenshare_selected"];
    return button;
}

+ (CustomButton *)swapCam {
    CustomButton *button = [self buttonWithFrame:kDefRect
                           backgroundColor:kDefBackgroundColor
                             selectedColor:kDefSelectedColor selectedTitle:@"Swap cam" unSelectedTitle:@"Swap cam"];
    button.pushed = YES;
    button.iconView = [self iconViewWithNormalImage:@"switchCamera"
                                      selectedImage:@"abort_swap"];
    return button;
}

+ (CustomButton *)decline {
    CustomButton *button = [self buttonWithFrame:kDefRect
                           backgroundColor:kDefDeclineColor
                             selectedColor:kDefSelectedColor selectedTitle:@"End call" unSelectedTitle:@"End call"];
    button.pushed = YES;
    button.iconView = [self iconViewWithNormalImage:@"decline-ic"
                                      selectedImage:@"decline-ic"];
    return button;
}

@end
