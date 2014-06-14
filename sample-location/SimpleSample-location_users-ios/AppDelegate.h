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

@class SplashViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) SplashViewController* splashController;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;

@end
