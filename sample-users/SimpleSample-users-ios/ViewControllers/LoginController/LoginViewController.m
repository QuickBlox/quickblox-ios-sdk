//
//  LoginViewController.m
//  SimpleSample-users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"

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

// User Sign In
- (IBAction)next:(id)sender
{
    // Authenticate user
    [QBRequest logInWithUserEmail:login.text password:password.text successBlock:^(QBResponse *response, QBUUser *user) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];

    [activityIndicator startAnimating];
}

- (IBAction)back:(id)sender 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginWithFaceBook:(id)sender {
    [QBUsers logInWithSocialProvider:@"facebook" scope:nil delegate:self];
}

- (IBAction)loginWithTwitter:(id)sender {
    [QBUsers logInWithSocialProvider:@"twitter" scope:nil delegate:self];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result{
    
    // QuickBlox User authenticate result
    if([result isKindOfClass:[QBUUserLogInResult class]]){
		
        // Success result
        if(result.success){
            
            QBUUserLogInResult *res = (QBUUserLogInResult *)result;
            
            // save current user
            mainController.currentUser = res.user;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentification successful" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            [mainController loggedIn];
		
        // Errors
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:[result.errors description]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            alert.tag = 1;
            [alert show];
        }
    }
    
    [activityIndicator stopAnimating];
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