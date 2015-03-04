//
//  BaseViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "BaseViewController.h"
#import "CornerView.h"
#import "ConnectionManager.h"
#import "IAButton.h"

@implementation BaseViewController

- (void)configureAIButton:(IAButton *)button
            withImageName:(NSString *)name
                  bgColor:(UIColor *)bgColor
            selectedColor:(UIColor *)selectedColor {
    
    UIImage *icon = [UIImage imageNamed:name];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    button.backgroundColor = bgColor;
    button.selectedColor = selectedColor;
    [button setIconView:iconView];
}

- (UIBarButtonItem *)cornerBarButtonWithColor:(UIColor *)color
                                         title:(NSString *)title
                                didTouchesEnd:(void(^)(void))action {
    
    return ({
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:({
            
            CornerView *cornerView = [[CornerView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            cornerView.touchesEndAction = action;
            cornerView.userInteractionEnabled = YES;
            cornerView.bgColor = color;
            cornerView.title = title;
            cornerView;
        })];
    
        backButtonItem;
    });
}

- (void)setDefaultBackBarButtonItem:(void(^)(void))didTouchesEndAction {
    
    UIBarButtonItem *backBarButtonItem =
    [self cornerBarButtonWithColor:ConnectionManager.instance.me.color
                              title:[NSString stringWithFormat:@"%lu", (unsigned long)ConnectionManager.instance.me.index + 1]
                     didTouchesEnd:^
     {
         didTouchesEndAction();
     }];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (UIView *)headerViewWithFrame:(CGRect)headerRect text:(NSString *)text {
    
    return ({
        
        UIView *infoHeaderView = [[UIView alloc] initWithFrame:headerRect];
        infoHeaderView.backgroundColor = [UIColor colorWithWhite:0.965 alpha:0.890];
        infoHeaderView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        
        [infoHeaderView addSubview:({
            
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:headerRect];
            infoLabel.text = text;
            infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
            infoLabel.textColor = [UIColor colorWithRed:0.248 green:0.267 blue:0.305 alpha:1.000];
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.numberOfLines = 0;
            infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            infoLabel;
        })];
        
        infoHeaderView;
    });
}

@end
