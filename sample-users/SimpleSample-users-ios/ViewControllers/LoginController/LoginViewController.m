//
//  LoginViewController.m
//  SimpleSample-users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"

@interface LoginViewController ()

@property (nonatomic, strong) IBOutlet UITextField *login;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController
@synthesize login;
@synthesize password;
@synthesize activityIndicator;
@synthesize mainController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [password resignFirstResponder];
    [login resignFirstResponder];
}

- (void (^)(QBResponse *response, QBUUser *user))successBlock
{
    return ^(QBResponse *response, QBUUser *user) {
        // save current user
        mainController.currentUser = user;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentification successful" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [mainController loggedIn];
        [activityIndicator stopAnimating];
    };
}

- (QBRequestErrorBlock)errorBlock
{
    return ^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
        [activityIndicator stopAnimating];
    };
}

// User Sign In
- (IBAction)next:(id)sender
{
    // Authenticate user
    [QBRequest logInWithUserEmail:login.text password:password.text successBlock:[self successBlock] errorBlock:[self errorBlock]];

    [activityIndicator startAnimating];
}

- (IBAction)back:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginWithFaceBook:(id)sender
{
    [QBRequest logInWithSocialProvider:@"facebook" scope:nil successBlock:[self successBlock] errorBlock:[self errorBlock]];
}

- (IBAction)loginWithTwitter:(id)sender
{
    [QBRequest logInWithSocialProvider:@"twitter" scope:nil successBlock:[self successBlock] errorBlock:[self errorBlock]];
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
    if(alertView.tag != 1){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end