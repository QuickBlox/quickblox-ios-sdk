//
//  LoginViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSLLoginViewController.h"
#import "SSLDataManager.h"
#import <MTBlockAlertView.h>

@interface SSLLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *loginTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSLLoginViewController

- (void(^)(QBResponse *, QBUUser *))onSuccess
{
    return ^(QBResponse *response, QBUUser *user) {
        [[SSLDataManager instance] saveCurrentUser:user];
        
        [MTBlockAlertView showWithTitle:@"Authentification successful"
                                message:nil
                      cancelButtonTitle:@"Ok"
                       otherButtonTitle:nil
                         alertViewStyle:UIAlertViewStyleDefault
                        completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
        [self.activityIndicator stopAnimating];
    };
}

- (void(^)(QBResponse *))onFailure
{
    return ^(QBResponse *response) {
        [MTBlockAlertView showWithTitle:@"Errors"
                                message:[response.error description]
                      cancelButtonTitle:@"Ok"
                       otherButtonTitle:nil
                         alertViewStyle:UIAlertViewStyleDefault
                        completionBlock:nil];
        [self.activityIndicator stopAnimating];
    };
}

- (void)login
{
    [QBRequest logInWithUserLogin:self.loginTextField.text
                         password:self.passwordTextField.text
                     successBlock:[self onSuccess]
                       errorBlock:[self onFailure]];
    
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

@end