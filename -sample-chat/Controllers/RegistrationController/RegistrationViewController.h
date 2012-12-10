//
//  RegistrationViewController.h
//  SimpleSample-chat_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//


@interface RegistrationViewController : UIViewController <ActionStatusDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *userName;
    UITextField *password;
    UITextField *retypePassword;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *retypePassword;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;

@end