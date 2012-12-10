//
//  AppDelegate.h
//  SimpleSample-messages_users-ios
//
//  Created by Igor Khomenko on 2/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class sets QuickBlox credentials
// Then shows splash screen that creates QuickBlox session in order to use QuickBlox API.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) SplashViewController* splashViewController;

@end
