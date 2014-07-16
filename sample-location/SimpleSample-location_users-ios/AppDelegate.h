//
//  AppDelegate.h
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class sets QuickBlox credentials
// Then shows splash screen that creates QuickBlox session in order to use QuickBlox API.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) SplashViewController* splashController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
