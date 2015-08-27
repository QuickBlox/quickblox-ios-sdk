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

@interface SignInTableViewController ()

@property (nonatomic, weak) IBOutlet UITextField *loginTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@end

@implementation SignInTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginTextField.text = @"samuel27";
    self.passwordTextField.text = @"samuel27";
}

- (IBAction)signInButtonTouched:(id)sender
{
    NSString *login = self.loginTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [SVProgressHUD showWithStatus:@"Signing in"];
    
    __weak typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:login password:password successBlock:^(QBResponse *response, QBUUser *user) {
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
}

@end
