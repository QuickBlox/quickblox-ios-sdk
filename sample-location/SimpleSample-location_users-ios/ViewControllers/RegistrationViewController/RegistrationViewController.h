//
//  RegistrationViewController.h
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
//
// This class enables new user registration QB user
//

@interface RegistrationViewController : UIViewController <QBActionStatusDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    UITextField *userName;
    UITextField *password;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, strong) IBOutlet UITextField *userName;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;

@end