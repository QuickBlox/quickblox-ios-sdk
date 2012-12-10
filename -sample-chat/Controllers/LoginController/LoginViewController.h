//
//  LoginViewController.h
//  SimpleSample-chat_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

@interface LoginViewController : UIViewController <ActionStatusDelegate, UIAlertViewDelegate, UITextFieldDelegate> {    
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