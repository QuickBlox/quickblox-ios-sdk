//
//  SignUpTableViewController.m
//  sample-users
//
//  Created by Quickblox Team on 8/27/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "SignUpTableViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface SignUpTableViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *loginTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmationTextField;

@end

@implementation SignUpTableViewController

- (BOOL)isPasswordConfirmed
{
    BOOL confirmed;
    if (self.passwordTextField.text == nil || self.passwordTextField.text.length == 0) {
        confirmed = NO;
    } else if (self.confirmationTextField.text == nil || self.confirmationTextField.text.length == 0) {
        confirmed = NO;
    } else {
        confirmed = [self.passwordTextField.text isEqualToString:self.confirmationTextField.text];
    }
    
    self.passwordTextField.backgroundColor = confirmed ? [UIColor whiteColor] : [UIColor redColor];
    self.confirmationTextField.backgroundColor = confirmed ? [UIColor whiteColor] : [UIColor redColor];
    
    return confirmed;
}

- (BOOL)isLoginTextValid
{
    BOOL loginValid = (self.loginTextField.text != nil && self.loginTextField.text.length > 0);
    self.loginTextField.backgroundColor = loginValid ? [UIColor whiteColor] : [UIColor redColor];
    return loginValid;
}

- (IBAction)nextButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    BOOL confirmed = [self isPasswordConfirmed];
    BOOL nonEmptyLogin = [self isLoginTextValid];

    if (confirmed && nonEmptyLogin) {
        [SVProgressHUD showWithStatus:@"Signing up"];

        QBUUser *user = [QBUUser new];
        user.login = self.loginTextField.text;
        user.password = self.passwordTextField.text;
        
        NSString* password = user.password;

        __weak typeof(self)weakSelf = self;
        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
            [QBRequest logInWithUserLogin:user.login password:password successBlock:^(QBResponse *response, QBUUser *user) {
                [SVProgressHUD dismiss];
                
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } errorBlock:^(QBResponse *response) {
                [SVProgressHUD dismiss];
                
                NSLog(@"Errors=%@", [response.error description]);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[response.error  description]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }];
            
        } errorBlock:^(QBResponse *response) {
            [SVProgressHUD dismiss];
            
            NSLog(@"Errors=%@", [response.error description]);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[response.error  description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.backgroundColor = [UIColor whiteColor];
}

@end
