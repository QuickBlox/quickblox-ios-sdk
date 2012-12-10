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

- (void)viewDidUnload{
    self.wheel = nil;

    [super viewDidUnload];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    // Your app connects to QuickBlox server here.
    //
    // Create extended session request (for push notifications)
    QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
    extendedAuthRequest.devicePlatorm = DevicePlatformiOS;
    extendedAuthRequest.deviceUDID = [[UIDevice currentDevice] uniqueIdentifier];
    extendedAuthRequest.userLogin = @"sam";
    extendedAuthRequest.userPassword = @"sam";
    
    // QuickBlox session creation
    [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
    
    [extendedAuthRequest release];
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.wheel.frame;
        frame.origin.y += 44;
        [self.wheel setFrame:frame];
    }
}

- (void)hideSplash {
    // hide splash & show main controller
    [self presentModalViewController:[[[MainViewController alloc] init] autorelease] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    // QuickBlox application authorization result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){
            // Hide splash & show main controller
            
            // Register as subscriber for Push Notifications
            [QBMessages TRegisterSubscriptionWithDelegate:self];
            
            [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
            
        // show Errors
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                            message:[result.errors description]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", "")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

@end