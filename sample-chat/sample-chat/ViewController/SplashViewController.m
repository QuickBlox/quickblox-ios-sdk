//
//  SplashViewController.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "SplashViewController.h"

#define demoUserLogin @"igorquickblox"
#define demoUserPassword @"igorquickblox"

@interface SplashViewController () <QBActionStatusDelegate>

@end

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = demoUserLogin;
    extendedAuthRequest.userPassword = demoUserPassword;
    //
	[QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){

            QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
            
            // Save current user
            //
            QBUUser *currentUser = [QBUUser user];
            currentUser.ID = res.session.userID;
            currentUser.password = demoUserPassword;
            //
            [[LocalStorageService shared] setCurrentUser:currentUser];
            
            // Login to QuickBlox Chat
            //
            [[ChatService instance] loginWithUser:currentUser completionBlock:^{
                
                // hide alert after delay
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification object:nil];
                });
            }];

        }else{
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
}

@end
