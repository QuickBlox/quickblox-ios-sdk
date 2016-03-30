//
// Created by Anton Sokolchenko on 3/30/16.
// Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginViewControllerInput <NSObject>

- (void)enableInput;
- (void)disableInput;

- (void)showViewController:(UIViewController *)viewController;

- (NSArray *)tags;
- (NSString *)userName;

@end