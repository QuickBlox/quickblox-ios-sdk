//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewControllerOutput.h"
#import "LoginViewControllerInput.h"

/**
 *  LoginViewControllerManager class that handles actions from LoginViewControllerOutput
 *  And manages LoginViewController
 */
@interface LoginViewControllerManager : NSObject <LoginViewControllerOutput>

/**
 *  LoginViewController input to retrieve data from and send methods to LoginViewController
 */
@property (nonatomic, weak) id<LoginViewControllerInput> input;

@end