//
//  BaseViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "BaseViewController.h"
#import "CornerView.h"
#import "ChatManager.h"
#import "UsersDataSource.h"
#import "QBUUser+IndexAndColor.h"

@implementation BaseViewController

- (UIBarButtonItem *)cornerBarButtonWithColor:(UIColor *)color
                                         title:(NSString *)title
                                didTouchesEnd:(dispatch_block_t)action {
    
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

- (void)setDefaultBackBarButtonItem:(dispatch_block_t)didTouchesEndAction {
    
    UIBarButtonItem *backBarButtonItem =
    [self cornerBarButtonWithColor:UsersDataSource.instance.currentUser.color
                              title:[NSString stringWithFormat:@"%tu", UsersDataSource.instance.currentUser.index + 1]
                     didTouchesEnd:^
     {
         didTouchesEndAction();
     }];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

@end
