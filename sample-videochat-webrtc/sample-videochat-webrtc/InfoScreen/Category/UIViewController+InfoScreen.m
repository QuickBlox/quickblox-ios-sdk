//
//  UIViewController+InfoScreen.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 1/2/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "UIViewController+InfoScreen.h"
#import "InfoTableViewController.h"

@implementation UIViewController (InfoScreen)

- (void)addInfoButton; {
    BOOL needAdd = YES;
    for (UIBarButtonItem *barButton in self.navigationItem.rightBarButtonItems) {
        if ([barButton respondsToSelector:@selector(didTapInfoButton:)]) {
            needAdd = NO;
        }
    }
    
    if (needAdd == NO) {
        return;
    }
    UIBarButtonItem *infoButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-info"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapInfoButton:)];
    infoButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 4.0f, -4.0f, -4.0f);
    infoButtonItem.tintColor = UIColor.whiteColor;
    if (self.navigationItem.rightBarButtonItems.count == 0) {
        self.navigationItem.rightBarButtonItem = infoButtonItem;
    } else if (self.navigationItem.rightBarButtonItems.count > 0) {
        NSMutableArray* rightBarButtonItems = self.navigationItem.rightBarButtonItems.mutableCopy;
        [rightBarButtonItems addObject:infoButtonItem];
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}

- (void)didTapInfoButton:(UIBarButtonItem *)sender {
    UIStoryboard* infoStoryboard = [UIStoryboard storyboardWithName:
                                    @"InfoScreen" bundle:[NSBundle mainBundle]];
    UITableViewController *infoController = [infoStoryboard instantiateViewControllerWithIdentifier:@"InfoTableViewController"];
    [self.navigationController pushViewController:infoController animated:YES];
}

@end
