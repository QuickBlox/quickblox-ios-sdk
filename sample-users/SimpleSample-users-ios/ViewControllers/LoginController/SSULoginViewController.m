//
//  LoginViewController.m
//  SimpleSample-users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSULoginViewController.h"
#import "SSUMainViewController.h"
#import "SSUUserCache.h"
#import "SSULoginState.h"

@interface SSULoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *loginTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSULoginViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passwordTextField resignFirstResponder];
    [self.loginTextField resignFirstResponder];
}

- (void)successfullLoginWithUser:(QBUUser *)user
{
    self.loginState.isLoggedIn = YES;
    
    [[SSUUserCache instance] saveUser:user];
    
    [MTBlockAlertView showWithTitle:@"Authentification successful" message:nil completionBlock:^(UIAlertView *alertView) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.activityIndicator stopAnimating];
}

- (void (^)(QBResponse *response, QBUUser *user))successBlock
{
    @weakify(self);
    return ^(QBResponse *response, QBUUser *user) {
        @strongify(self);
        [self successfullLoginWithUser:user];
    };
}

- (QBRequestErrorBlock)errorBlock
{
    @weakify(self);
    return ^(QBResponse *response) {
        @strongify(self);
        self.loginState.isLoggedIn = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        [self.activityIndicator stopAnimating];
    };
}

- (void)login
{
    // Authenticate user
    [QBRequest logInWithUserLogin:self.loginTextField.text password:self.passwordTextField.text
                     successBlock:[self successBlock] errorBlock:[self errorBlock]];
    
    [self.activityIndicator startAnimating];
}

- (IBAction)next:(id)sender
{
    [self login];
}

- (IBAction)loginWithFaceBook:(id)sender
{
    [QBRequest logInWithSocialProvider:@"facebook" scope:@[] successBlock:[self successBlock] errorBlock:[self errorBlock]];
}

- (IBAction)loginWithTwitter:(id)sender
{
    [QBRequest logInWithSocialProvider:@"twitter" scope:@[] successBlock:[self successBlock] errorBlock:[self errorBlock]];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self login];
    return YES;
}

@end