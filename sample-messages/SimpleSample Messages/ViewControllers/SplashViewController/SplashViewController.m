//
//  SplashViewController.m
//  SimpleSample-messages_users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"

@implementation SplashViewController
@synthesize wheel = _wheel;

- (void) viewDidLoad {
    [super viewDidLoad];

    // Your app connects to QuickBlox server here.
    //
    // Create extended session request (for push notifications)
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = @"injoitUser1";
    extendedAuthRequest.userPassword = @"injoitUser1";
    
    // QuickBlox session creation
    [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.wheel.frame;
        frame.origin.y += 44;
        [self.wheel setFrame:frame];
    }
}

- (void)hideSplash {
    // hide splash & show main controller
    [self presentViewController:[[MainViewController alloc] init] animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    // Success result
    if(result.success){
        
        // QuickBlox session creation result
        if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
            
            // Register as subscriber for Push Notifications
            [QBMessages TRegisterSubscriptionWithDelegate:self];
            
        // QuickBlox register for Push Notifications result
        }else if([result isKindOfClass:[QBMRegisterSubscriptionTaskResult class]]){
            
            // Hide splash & show main controller
            [self hideSplash];
        }
        
    // show Errors
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[result.errors description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end