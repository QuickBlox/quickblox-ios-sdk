//
//  RegistrationViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/17/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "RegistrationViewController.h"

#define loginContext @"loginContext"
#define registrationContext @"registrationContext"

@interface RegistrationViewController () <UITextFieldDelegate, QBActionStatusDelegate>

@property (nonatomic, weak) IBOutlet UITextField *loginTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

- (IBAction)back:(id)sender;
- (IBAction)registration:(id)sender;

@end

@implementation RegistrationViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // configure navigation bar for iOS7
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGFloat height = self.navigationBar.frame.size.height + statusBarFrame.size.height;
        self.navigationBar.frame = CGRectMake(0, 0, self.navigationBar.frame.size.width, height);
    }
}

#pragma mark
#pragma mark Actions

- (IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registration:(id)sender{
    QBUUser *user = [QBUUser user];
	user.password = self.passwordTextField.text;
    user.login = self.loginTextField.text;
    
    // create User
	[QBUsers signUp:user delegate:self context:registrationContext];
    
    [self.activityIndicatorView startAnimating];
    
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result context:(void *)contextInfo{
    
    // QuickBlox User creation result
    if([result isKindOfClass:[QBUUserResult class]]){
        
        // Success result
		if(result.success){

            if([((__bridge NSString *)contextInfo) isEqualToString:loginContext]){
                
                // Save current user
                //
                QBUUserLogInResult *res = (QBUUserLogInResult *)result;
                res.user.password = self.passwordTextField.text;
                [[LocalStorageService shared] setCurrentUser: res.user];
                
                
                // Login to Chat
                //
                [[ChatService instance] loginWithUser:[LocalStorageService shared].currentUser completionBlock:^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have successfully logged in"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles: nil];
                    [alert show];
                    //
                    // hide alert after delay
                    double delayInSeconds = 2.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [alert dismissWithClickedButtonIndex:0 animated:YES];
                    });
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                
            }else{
                // Login
                [QBUsers logInWithUserLogin:self.loginTextField.text
                                   password:self.passwordTextField.text
                                   delegate:self context:loginContext];
            }

        // Errors
        }else {
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            [self.activityIndicatorView stopAnimating];
		}
	}
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
