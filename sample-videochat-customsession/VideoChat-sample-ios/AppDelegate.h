//
//  AppDelegate.h
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//
//
// This class sets QuickBlox credentials
// Then shows splash screen where you have to create QuickBlox session with user in order to use QuickBlox API.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
}

@property (strong, nonatomic) UIWindow *window;

/* VideoChat test opponents */
@property (strong, nonatomic) NSArray *testOpponents;

/* Current logged in test user*/
@property (assign, nonatomic) int currentUser;

@end
