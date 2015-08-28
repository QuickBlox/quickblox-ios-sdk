//
//  LoginViewController.h
//  sample-location
//
//  Created by Quickblox Team on 04.10.11.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//
//
// This class enables log in for QB users.
// Login window is only called when user wants to do some action with the map,
// for example mark his position for other users.
//

typedef NS_ENUM(NSInteger, SSLAuthViewControllerMode) {
    SSLAuthViewControllerModeLogIn = 0,
    SSLAuthViewControllerModeSignUp,
};

@interface SSLAuthViewController : UIViewController

@property (nonatomic, assign) SSLAuthViewControllerMode mode;

@end