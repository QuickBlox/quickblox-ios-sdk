//
//  MainTabBarController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/17/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController

- (void)showUserIsNotLoggedInAlert;
- (void)showSplashViewController;
- (void)showLoginViewController;
- (void)showRegistrationViewController;

@end
