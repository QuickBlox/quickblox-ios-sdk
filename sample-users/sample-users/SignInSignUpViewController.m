//
//  SignInSignUpViewController.m
//  sample-users
//
//  Created by Igor Khomenko on 6/11/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "SignInSignUpViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface SignInSignUpViewController ()

@property (nonatomic) IBOutlet UITextField *loginTextField;
@property (nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation SignInSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.isTypeSignIn){
        self.title = @"Sign In";
        [self.actionButton setTitle:@"Sign In" forState:UIControlStateNormal];
        self.loginTextField.text = @"samuel27";
        self.passwordTextField.text = @"samuel27";
    }else{
        self.title = @"Sign Up";
        [self.actionButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action:(id)sender{
    NSString *login = self.loginTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if(self.isTypeSignIn){
        [SVProgressHUD showWithStatus:@"Signing in"];
        
        [QBRequest logInWithUserLogin:login password:password successBlock:^(QBResponse *response, QBUUser *user) {
            [SVProgressHUD dismiss];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
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
    }else{
        [SVProgressHUD showWithStatus:@"Signing up"];
        
        QBUUser *user = [QBUUser new];
        user.login = login;
        user.password = password;
        
        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
            [QBRequest logInWithUserLogin:login password:password successBlock:^(QBResponse *response, QBUUser *user) {
                [SVProgressHUD dismiss];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
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

@end
