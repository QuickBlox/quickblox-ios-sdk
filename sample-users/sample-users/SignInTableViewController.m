//
//  SignInTableViewController.m
//  sample-users
//
//  Created by Quickblox Team on 8/27/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "SignInTableViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface SignInTableViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *loginTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@end

@implementation SignInTableViewController

- (BOOL)isLoginEmpty
{
    BOOL emptyLogin = self.loginTextField.text.length == 0;
    self.loginTextField.backgroundColor = emptyLogin ? [UIColor redColor] : [UIColor whiteColor];
    return emptyLogin;
}

- (BOOL)isPasswordEmpty
{
    BOOL emptyPassword = self.passwordTextField.text.length == 0;
    self.passwordTextField.backgroundColor = emptyPassword ? [UIColor redColor] : [UIColor whiteColor];
    return emptyPassword;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginTextField.text = @"samuel27";
    self.passwordTextField.text = @"samuel27";
}

- (IBAction)nextButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    BOOL notEmptyLogin = ![self isLoginEmpty];
    BOOL notEmptyPassword = ![self isPasswordEmpty];
    
    if (notEmptyLogin && notEmptyPassword) {
        NSString *login = self.loginTextField.text;
        NSString *password = self.passwordTextField.text;
        
        [SVProgressHUD showWithStatus:@"Signing in"];

        __weak typeof(self)weakSelf = self;
        [QBRequest logInWithUserLogin:login password:password successBlock:^(QBResponse *response, QBUUser *user) {
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
