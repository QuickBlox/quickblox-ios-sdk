//
//  RegistrationViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSLRegistrationViewController.h"

@interface SSLRegistrationViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSLRegistrationViewController

- (void)signUp
{
    // Create QuickBlox User entity
    QBUUser *user = [QBUUser user];
	user.password = self.passwordTextField.text;
    user.login = self.userNameTextField.text;
    
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration was successful. Please now sign in."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } errorBlock:^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
    
    [self.activityIndicator startAnimating];
}

- (IBAction)nextButtonTouched:(id)sender
{
    [self signUp];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self nextButtonTouched:nil];
    return YES;
}

#pragma mark
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passwordTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
}

@end