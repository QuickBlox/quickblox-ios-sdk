//
//  SpalshViewController.m
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize activityIndicator;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loginAsUser1:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentUser = 1;
    
    
    // Your app connects to QuickBlox server here.
    //
    // Create extended session request with user authorization
    //
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = appDelegate.testOpponents[0];
    extendedAuthRequest.userPassword = appDelegate.testOpponents[1];
    [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
    
    [activityIndicator startAnimating];
    
    loginAsUser1Button.enabled = NO;
    loginAsUser2Button.enabled = NO;
}
- (IBAction)loginAsUser2:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentUser = 2;
    
    
    // Your app connects to QuickBlox server here.
    //
    // Create extended session request with user authorization
    //
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = appDelegate.testOpponents[3];
    extendedAuthRequest.userPassword = appDelegate.testOpponents[4];
    [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
    
    [activityIndicator startAnimating];
    
    loginAsUser1Button.enabled = NO;
    loginAsUser2Button.enabled = NO;
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){
            
            // Set QuickBlox Chat delegate
            //
            [QBChat instance].delegate = self;
            
            QBUUser *user = [QBUUser user];
            user.ID = ((QBAAuthSessionCreationResult *)result).session.userID;
            user.password = appDelegate.currentUser == 1 ? appDelegate.testOpponents[1] : appDelegate.testOpponents[4];
            
            // Login to QuickBlox Chat
            //
            [[QBChat instance] loginWithUser:user];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[result errors] description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            loginAsUser1Button.enabled = YES;
            loginAsUser2Button.enabled = YES;
        }
    }
}


#pragma mark -
#pragma mark QBChatDelegate

- (void)chatDidLogin{
    // Show Main controller
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MainViewController *mainViewController = [[MainViewController alloc] init];
    mainViewController.opponentID = appDelegate.currentUser == 1 ? appDelegate.testOpponents[5] : appDelegate.testOpponents[2];
    [self presentViewController:mainViewController animated:YES completion:nil];
}

- (void)chatDidNotLogin{
    loginAsUser1Button.enabled = YES;
    loginAsUser2Button.enabled = YES;
}

@end
