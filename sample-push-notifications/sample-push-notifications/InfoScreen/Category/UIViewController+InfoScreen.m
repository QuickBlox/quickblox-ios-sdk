//
//  UIViewController+InfoScreen.m
//  sample-conference-videochat
//
//  Created by Vladimir Nybozhinsky on 1/2/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIViewController+InfoScreen.h"
#import "InfoTableViewController.h"

@implementation UIViewController (InfoScreen)

- (void)showInfoButton {
    BOOL needAdd = YES;
    for (UIBarButtonItem *barButton in self.navigationItem.rightBarButtonItems) {
        if ([barButton respondsToSelector:@selector(didTapInfoButton:)]) {
            needAdd = NO;
        }
    }
    
    if (needAdd == false) {
        return;
    }
    UIBarButtonItem *infoButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-info"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapInfoButton:)];
        self.navigationItem.leftBarButtonItem = infoButtonItem;
}

- (void)didTapInfoButton:(UIBarButtonItem *)sender {
    UIStoryboard* infoStoryboard = [UIStoryboard storyboardWithName:
                                    @"InfoScreen" bundle:[NSBundle mainBundle]];
    UITableViewController *infoController = [infoStoryboard instantiateViewControllerWithIdentifier:@"InfoTableViewController"];
    [self.navigationController pushViewController:infoController animated:YES];
}

@end
