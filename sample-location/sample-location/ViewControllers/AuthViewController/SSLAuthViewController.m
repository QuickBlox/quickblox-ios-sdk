//
//  LoginViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSLAuthViewController.h"
#import "SSLDataManager.h"

@interface SSLAuthViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *loginTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionBarButtonItem;

@end

@implementation SSLAuthViewController

#pragma mark - View Controller

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureForMode:self.mode];
}

#pragma mark - Configuration

- (void)configureForMode:(SSLAuthViewControllerMode)mode {
    
    if (mode == SSLAuthViewControllerModeLogIn) {
        
        self.loginTextField.text = @"injoitUser1";
        self.passwordTextField.text = @"injoitUser1";
        self.navigationItem.rightBarButtonItem.title = @"Log In";
        
    } else {
        
        self.loginTextField.text = nil;
        self.passwordTextField.text = nil;
        self.navigationItem.rightBarButtonItem.title = @"Sign Up";
    }
}

#pragma mark - User Action

- (IBAction)actionBarButtonItemClicked:(id)sender
{
    [self authAction];
}

- (IBAction)cancelBarButtonItemClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action

- (void)authAction
{
    if (self.mode == SSLAuthViewControllerModeLogIn) {
        [self signIn];
    } else {
        [self signUp];
    }
}

- (void)signIn
{
    [QBRequest logInWithUserLogin:self.loginTextField.text
                         password:self.passwordTextField.text
                     successBlock:[self onSignInSuccess]
                       errorBlock:[self onFailure]];
    
    [self.activityIndicator startAnimating];
}

- (void)signUp
{
    // Create QuickBlox User entity
    QBUUser *user = [QBUUser user];
    user.password = self.passwordTextField.text;
    user.login = self.loginTextField.text;
    
    [QBRequest signUp:user
         successBlock:[self onSignUpSuccess]
           errorBlock:[self onFailure]];
    
    [self.activityIndicator startAnimating];
}

#pragma mark - Completion Blocks

- (void(^)(QBResponse *, QBUUser *))onSignInSuccess
{
    return ^(QBResponse *response, QBUUser *user) {
        [[SSLDataManager instance] saveCurrentUser:user];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentification successful"
                                                            message:[response.error description]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [self.activityIndicator stopAnimating];
    };
}

- (void(^)(QBResponse *, QBUUser *))onSignUpSuccess
{
    return ^(QBResponse *response, QBUUser *user) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration was successful. Please now sign in."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self.activityIndicator stopAnimating];
    };
}

- (void(^)(QBResponse *))onFailure
{
    return ^(QBResponse *response) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:[response.error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [self.activityIndicator stopAnimating];
    };
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.loginTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self authAction];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passwordTextField resignFirstResponder];
    [self.loginTextField resignFirstResponder];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

@end