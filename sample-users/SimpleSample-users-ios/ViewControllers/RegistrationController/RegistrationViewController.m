//
//  RegistrationViewController.m
//  SimpleSample-users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "RegistrationViewController.h"

@interface RegistrationViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userName;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation RegistrationViewController
@synthesize userName;
@synthesize password;
@synthesize activityIndicator;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [password resignFirstResponder];
    [userName resignFirstResponder];
}

// User Sign Up
- (IBAction)next:(id)sender 
{
    // Create QuickBlox User entity
    QBUUser *user = [QBUUser user]; 
	user.password = password.text;
    user.login = userName.text;
    
    // create User
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration was successful. Please now sign in."
                                                        message:nil delegate:self
                                              cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [activityIndicator stopAnimating];
    } errorBlock:^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [activityIndicator stopAnimating];
    }];
    
    [activityIndicator startAnimating];
}

- (IBAction)back:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
    [_textField resignFirstResponder];
    [self next:nil];
    return YES;
}


#pragma mark
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end