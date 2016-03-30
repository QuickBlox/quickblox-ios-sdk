//
//  BaseViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "BaseViewController.h"
#import "CornerView.h"
#import "UsersDataSourceProtocol.h"

@implementation BaseViewController

- (UIBarButtonItem *)cornerBarButtonWithColor:(UIColor *)color
                                         title:(NSString *)title
                                didTouchesEnd:(dispatch_block_t)action {

	
	CornerView *cornerView = [[CornerView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	cornerView.touchesEndAction = action;
	cornerView.userInteractionEnabled = YES;
	cornerView.bgColor = color;
	
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cornerView];

    backButtonItem.isAccessibilityElement = YES;

    return backButtonItem;
}

- (void)setDefaultBackBarButtonItem:(dispatch_block_t)didTouchesEndAction {
	
	UIColor *currentUserColor = [[SampleCore usersDataSource] colorAtCurrentUser];
	NSUInteger currentUserIndex = [[SampleCore usersDataSource] indexOfCurrentUser];
	
    UIBarButtonItem *backBarButtonItem =
    [self cornerBarButtonWithColor:currentUserColor
                              title:[NSString stringWithFormat:@"%tu", currentUserIndex + 1]
                     didTouchesEnd:^
     {
         didTouchesEndAction();
     }];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

@end
