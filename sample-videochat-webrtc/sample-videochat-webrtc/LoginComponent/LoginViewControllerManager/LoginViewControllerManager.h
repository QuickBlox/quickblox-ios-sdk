//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewControllerOutput.h"
#import "LoginViewControllerInput.h"

@interface LoginViewControllerManager : NSObject <LoginViewControllerOutput>

@property (nonatomic, weak) id<LoginViewControllerInput> input;

@end