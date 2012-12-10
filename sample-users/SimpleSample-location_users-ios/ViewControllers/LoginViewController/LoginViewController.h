//
//  LoginViewController.h
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
//
// This class enables log in for QB users.
// Login window is only called when user wants to do some action with the map,
// for example mark his position for other users.
//

@interface LoginViewController : UIViewController <QBActionStatusDelegate, UIAlertViewDelegate, UITextFieldDelegate> {    
    UITextField *login;
    UITextField *password;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, retain) IBOutlet UITextField *login;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;

@end