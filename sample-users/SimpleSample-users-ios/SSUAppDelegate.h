//
//  AppDelegate.h
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class sets QuickBlox credentials
// Then shows splash screen that creates QuickBlox session in order to use QuickBlox API.
//

@class SSUSplashViewController;

@interface SSUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SSUSplashViewController *splashController;

@end
