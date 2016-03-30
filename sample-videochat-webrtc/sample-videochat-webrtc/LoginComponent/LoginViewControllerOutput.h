//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginTagViewController;

@protocol LoginViewControllerOutput <NSObject>

- (void)loginViewControllerViewDidLoad:(LoginTagViewController *)loginViewController;

- (void)loginViewControllerDidTapLoginButton:(LoginTagViewController *)loginViewController;

@end