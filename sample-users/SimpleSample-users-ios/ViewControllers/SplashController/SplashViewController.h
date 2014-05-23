//
//  SplashController.h
//  SimpleSample-users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
//
// This class creates QuickBlox session in order to use QuickBlox API.
// Then hides splash screen & show main controller that shows how to work
// with QuickBlox Users module (in particular, how to Sign In, Sign Out, Sign Up
// retrieve all users, search users, edit user)
//

#import "MainViewController.h"

@interface SplashViewController : UIViewController <QBActionStatusDelegate>{
    
}
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *wheel;

- (void)hideSplash;

@end