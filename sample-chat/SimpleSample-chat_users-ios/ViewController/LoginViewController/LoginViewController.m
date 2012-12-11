//
//  LoginViewController.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginField;
@synthesize passwordField;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [self setTitle:@"Login"];
}

- (void)viewDidUnload
{
    [self setLoginField:nil];
    [self setPasswordField:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [loginField release];
    [passwordField release];
    [activityIndicator release];
    [super dealloc];
}

- (IBAction)loginWithFB:(id)sender {
    // Authenticate user through Facebook
    [QBUsers logInWithSocialProvider:@"facebook" scope:nil delegate:self];
}

- (IBAction)loginWithTitter:(id)sender {
    // Authenticate user through Twitter
    [QBUsers logInWithSocialProvider:@"twitter" scope:nil delegate:self];
}

- (IBAction)login:(id)sender {
    
    // Authenticate user
    [QBUsers logInWithUserLogin:self.loginField.text
                       password:self.passwordField.text
                       delegate:self
                        context:self.passwordField.text];
    
    [self.activityIndicator startAnimating];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result  context:(void *)contextInfo{
    
    // QuickBlox User authentication result
    if([result isKindOfClass:[QBUUserLogInResult class]]){
		
        // Success result
        if(result.success){
            
            QBUUserLogInResult *res = (QBUUserLogInResult *)result;
            
            // save current user
            [[DataManager shared] setCurrentUser: res.user];
            
            [[[DataManager shared] currentUser] setPassword:(NSString *)contextInfo];
            
            // Login to Chat
            [QBChat instance].delegate = self;
            [[QBChat instance] loginWithUser:[[DataManager shared] currentUser]];
            
            // Register as subscriber for Push Notifications
            [QBMessages TRegisterSubscriptionWithDelegate:nil];
            
        // Errors
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:[result.errors description]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            alert.tag = 1;
            [alert show];
            [alert release];
            
            [activityIndicator stopAnimating];
        }
    }
}

-(void)completedWithResult:(Result *)result{
    // QuickBlox User authentication result
    if([result isKindOfClass:[QBUUserLogInResult class]]){
		
        // Success result
        if(result.success){
            
            // If we are authenticating through Twitter/Facebook - we use token as user's password for Chat module
            [self completedWithResult:result context:[BaseService sharedService].token];
        }
    
    // Errors
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[result.errors description]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
        [alert release];
        
        [activityIndicator stopAnimating];
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag != 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark QBChatDelegate

// Chat delegate
-(void) chatDidLogin{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentification successful"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}

@end
