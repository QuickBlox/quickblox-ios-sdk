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

@interface SignUpTableViewController ()
@property (nonatomic, weak) IBOutlet UITextField *loginTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmationTextField;

@end

@implementation SignUpTableViewController

- (IBAction)signUpButtonTouched:(id)sender
{
#warning add validation
    [SVProgressHUD showWithStatus:@"Signing up"];
    
    QBUUser *user = [QBUUser new];
    user.login = self.loginTextField.text;
    user.password = self.passwordTextField.text;
    
    __weak typeof(self)weakSelf = self;
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        [QBRequest logInWithUserLogin:user.login password:user.password successBlock:^(QBResponse *response, QBUUser *user) {
            [SVProgressHUD dismiss];
            
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
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

@end
