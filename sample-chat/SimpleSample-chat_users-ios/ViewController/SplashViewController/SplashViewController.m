//
//  SpalshViewController.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"
#import "MainViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize activityIndicator;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
	[QBAuth createSessionWithDelegate:self];
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.activityIndicator.frame;
        frame.origin.y += 44;
        [self.activityIndicator setFrame:frame];
    }
}

-(void)hideSplash{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setDelegate:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [delegate release];
    [activityIndicator release];
    [super dealloc];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){
            
            // retrieve all users periodicaly
            if(((MainViewController *)self.delegate).requesAllUsersTimer == nil){
                
                ((MainViewController *)self.delegate).requesAllUsersTimer= [NSTimer scheduledTimerWithTimeInterval:120
                                                                                                            target:self.delegate
                                                                                                          selector:@selector(updateUsers)
                                                                                                          userInfo:nil
                                                                                                           repeats:YES];
                [((MainViewController *)self.delegate).requesAllUsersTimer fire];
            }
            
            // hide splash
            [self performSelector:@selector(hideSplash) withObject:nil afterDelay:0.5];
        }
    }
}

@end
