//
//  AppDelegate.h
//  SimpleSample-chat_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SplashController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ActionStatusDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) SplashController* splashController;

@end
