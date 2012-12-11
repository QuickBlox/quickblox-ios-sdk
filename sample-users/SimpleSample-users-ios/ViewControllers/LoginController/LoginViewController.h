//
//  LoginViewController.h
//  SimpleSample-users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
//
// This class enables log in for QB users.
// Login window is only called when user wants to do some action with the map,
// for example mark his position for other users.
//

#import "MainViewController.h"

@class MainViewController;

@interface LoginViewController : UIViewController <QBActionStatusDelegate, UIAlertViewDelegate, UITextFieldDelegate> {    
}
@property (nonatomic, retain) IBOutlet UITextField *login;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) IBOutlet MainViewController* mainController;

- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)loginWithFaceBook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;

@end