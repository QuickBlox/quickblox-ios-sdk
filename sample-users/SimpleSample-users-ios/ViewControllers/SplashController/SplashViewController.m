//
//  SplashViewController.m
//  SimpleSample-users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"

@implementation SplashViewController

- (void) viewDidLoad
{
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
    [QBAuth createSessionWithDelegate:self];
    
    [super viewDidLoad];
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.wheel.frame;
        frame.origin.y += 44;
        [self.wheel setFrame:frame];
    }
}

- (void)hideSplash
{
    // show main controller
    [self presentViewController:[[MainViewController alloc] init]  animated:YES completion:nil];
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
            [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
            
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
}

@end