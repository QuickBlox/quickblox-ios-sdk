//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginViewControllerInput;

/**
 *  LoginViewController delegate methods
 */
@protocol LoginViewControllerOutput <NSObject>

- (void)loginViewControllerViewDidLoad:(id<LoginViewControllerInput>)loginViewControllerInput;

- (void)loginViewControllerDidTapLoginButton:(id<LoginViewControllerInput>)loginViewControllerInput;

@end