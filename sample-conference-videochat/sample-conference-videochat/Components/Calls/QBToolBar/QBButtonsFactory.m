//
//  QBButtonsFactory.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 23/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "QBButtonsFactory.h"
#import "QBButton.h"

const CGRect kDefRect = {0, 0, 44, 44};
const CGRect kDefDeclineRect = {0, 0, 96, 44};
const CGRect kDefCircleDeclineRect = {0, 0, 44, 44};

#define kDefBackgroundColor [UIColor colorWithRed:0.8118 green:0.8118 blue:0.8118 alpha:1.0]
#define kDefSelectedColor [UIColor colorWithRed:0.3843 green:0.3843 blue:0.3843 alpha:1.0]
#define kDefDeclineColor [UIColor colorWithRed:0.8118 green:0.0 blue:0.0784 alpha:1.0]
#define kDefAnswerColor [UIColor colorWithRed:0.1434 green:0.7587 blue:0.1851 alpha:1.0]

@implementation QBButtonsFactory

#pragma mark - Private

+ (QBButton *)buttonWithFrame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                selectedColor:(UIColor *)selectedColor  {
    
    QBButton *button = [[QBButton alloc] initWithFrame:frame];
    button.backgroundColor = backgroundColor;
    button.selectedColor = selectedColor;
    
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

+ (QBButton *)videoEnable {
    
    QBButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefBackgroundColor
                               selectedColor:kDefSelectedColor];
    button.pushed = YES;
    
    button.iconView = [self iconViewWithNormalImage:@"camera_on_ic"
                                      selectedImage:@"camera_off_ic"];
    return button;
}

+ (QBButton *)auidoEnable {
    
    QBButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefBackgroundColor
                               selectedColor:kDefSelectedColor];
    
    button.pushed = YES;
    
    button.iconView = [self iconViewWithNormalImage:@"mute_on_ic"
                                      selectedImage:@"mute_off_ic"];
    return button;
}

+ (QBButton *)dynamicEnable {
    
    QBButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefBackgroundColor
                               selectedColor:kDefSelectedColor];
    
    button.pushed = YES;
    
    button.iconView = [self iconViewWithNormalImage:@"dynamic_on_ic"
                                      selectedImage:@"dynamic_off_ic"];
    return button;
}

+ (QBButton *)screenShare {
    
    QBButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefBackgroundColor
                               selectedColor:kDefSelectedColor];
    
    button.iconView = [self iconViewWithNormalImage:@"screensharing_ic"
                                      selectedImage:@"screensharing_ic"];
    return button;
}

+ (QBButton *)answer {
    
    QBButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefAnswerColor
                               selectedColor:kDefSelectedColor];
    
    button.iconView = [self iconViewWithNormalImage:@"answer"
                                      selectedImage:@"answer"];
    return button;
}

+ (QBButton *)decline {
    
    QBButton *button = [self buttonWithFrame:kDefDeclineRect
                             backgroundColor:kDefDeclineColor
                               selectedColor:kDefSelectedColor];
    
    button.iconView = [self iconViewWithNormalImage:@"decline-ic"
                                      selectedImage:@"decline-ic"];
    return button;
}

+ (QBButton *)circleDecline {
    
    QBButton *button = [self buttonWithFrame:kDefCircleDeclineRect
                             backgroundColor:kDefDeclineColor
                               selectedColor:kDefSelectedColor];
    
    button.iconView = [self iconViewWithNormalImage:@"decline-ic"
                                      selectedImage:@"decline-ic"];
    return button;
}

@end
