//
//  RegistrationViewController.m
//  SimpleSample-users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSURegistrationViewController.h"

@interface SSURegistrationViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userName;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSURegistrationViewController
@synthesize userName;
@synthesize password;
@synthesize activityIndicator;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.password resignFirstResponder];
    [self.userName resignFirstResponder];
}

- (void)signUp
{
    [self.activityIndicator startAnimating];
    
    // Create QuickBlox User entity
    QBUUser *user = [QBUUser user];
	user.password = self.password.text;
    user.login = self.userName.text;
    
    @weakify(self);
    // create User
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        @strongify(self);
        [MTBlockAlertView showWithTitle:@"Registration was successful. Please now sign in."
                                message:nil completionBlock:^(UIAlertView *alertView) {
                                    @strongify(self);
                                    [self.navigationController popViewControllerAnimated:YES];
                                }];
        [self.activityIndicator stopAnimating];
    } errorBlock:^(QBResponse *response) {
        @strongify(self);
        [MTBlockAlertView showWithTitle:@"Errors" message:[response.error description]];
        [self.activityIndicator stopAnimating];
    }];
}


- (IBAction)signUpButtonTouched:(id)sender 
{
    [self signUp];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self signUp];
    return YES;
}


@end