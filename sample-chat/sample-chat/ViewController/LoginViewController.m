//
//  LoginViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/17/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "LoginViewController.h"

#define socialLoginContext @"socialLoginContext"
#define typicalLoginContext @"typicalLoginContext"

@interface LoginViewController () <UITextFieldDelegate, QBActionStatusDelegate>

@property (nonatomic, weak) IBOutlet UITextField *loginTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

- (IBAction)back:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)connectWithFacebook:(id)sender;
- (IBAction)connectWithTwitter:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // configure navigation bar for iOS7
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGFloat height = self.navigationBar.frame.size.height + statusBarFrame.size.height;
        self.navigationBar.frame = CGRectMake(0, 0, self.navigationBar.frame.size.width, height);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialDialogDidClose)
                                                 name:QuickbloxSocialDialogDidCloseNotification object:nil];
}

- (void)socialDialogDidClose{
    [self.activityIndicatorView stopAnimating];
}


#pragma mark
#pragma mark Actions

- (IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)login:(id)sender{
    // Login QuickBlox user
    //
    [QBUsers logInWithUserLogin:self.loginTextField.text
                       password:self.passwordTextField.text
                       delegate:self context:typicalLoginContext];
    
    [self.activityIndicatorView startAnimating];
}

- (IBAction)connectWithFacebook:(id)sender{
    // Login user with Facebook account
    //
    [QBUsers logInWithSocialProvider:@"facebook"
                               scope:nil
                            delegate:self context:socialLoginContext];
    
    [self.activityIndicatorView startAnimating];
}

- (IBAction)connectWithTwitter:(id)sender{
    // Login user with Twitter account
    //
    [QBUsers logInWithSocialProvider:@"twitter"
                               scope:nil
                            delegate:self context:socialLoginContext];
    
    [self.activityIndicatorView startAnimating];
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
            
            // Read about Chat password there http://quickblox.com/developers/Chat#Password
            //
            if([((__bridge NSString *)contextInfo) isEqualToString:socialLoginContext]){
                res.user.password = [QBBaseModule sharedModule].token;
            }else{
                res.user.password = self.passwordTextField.text;
            }
            // Save current user
            //
            [[LocalStorageService shared] setCurrentUser: res.user];

            
            // Login to QuickBlox Chat
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
            
        // Errors
        }else{
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
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
