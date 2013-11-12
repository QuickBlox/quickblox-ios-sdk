//
//  MainTabBarController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/17/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show splash
        [self showSplashViewController];
    });
}

- (void)showUserIsNotLoggedInAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You have to be logged in in order to start chat"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok" otherButtonTitles: @"Login", @"Register",  nil];
    [alert show];
}

- (void)showSplashViewController{
    [self performSegueWithIdentifier:kShowSplashViewControllerSegue sender:nil];
}

- (void)showLoginViewController{
    [self performSegueWithIdentifier:kShowLoginViewControllerSegue sender:nil];
}

- (void)showRegistrationViewController{
    [self performSegueWithIdentifier:kShowRegistrationViewControllerSegue sender:nil];
}


#pragma mark
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        // open Login controller
        [self showLoginViewController];
        return;
    }
    
    if(buttonIndex == 2){
        // open Register controller
        [self showRegistrationViewController];
        return;
    }
}


@end
