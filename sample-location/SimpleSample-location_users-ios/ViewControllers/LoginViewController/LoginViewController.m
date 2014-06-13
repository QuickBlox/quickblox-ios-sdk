//
//  LoginViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "LoginViewController.h"
#import "DataManager.h"

@interface LoginViewController () <QBActionStatusDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *loginTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController
@synthesize loginTextField;
@synthesize passwordTextField;
@synthesize activityIndicator;

- (void(^)(QBResponse *, QBUUser *))onSuccess
{
    return ^(QBResponse *response, QBUUser *user) {
        [[DataManager shared] setCurrentUser:user];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentification successful"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        [self.activityIndicator stopAnimating];
    };
}

- (void(^)(QBResponse *))onFailure
{
    return ^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
        [self.activityIndicator stopAnimating];
    };
}

- (void)login
{
    [QBRequest logInWithUserLogin:loginTextField.text password:passwordTextField.text successBlock:[self onSuccess] errorBlock:[self onFailure]];
    
    [self.activityIndicator startAnimating];
}

- (IBAction)nextButtonTouched:(id)sender
{
    [self login];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginWithFaceBook:(id)sender
{
    [QBRequest logInWithSocialProvider:@"facebook" scope:nil successBlock:[self onSuccess] errorBlock:[self onFailure]];
}

- (IBAction)loginWithTwitter:(id)sender
{
    [QBRequest logInWithSocialProvider:@"twitter" scope:nil successBlock:[self onSuccess] errorBlock:[self onFailure]];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self login];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passwordTextField resignFirstResponder];
    [self.loginTextField resignFirstResponder];
}

#pragma mark - 
#pragma marl UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag != 1){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end