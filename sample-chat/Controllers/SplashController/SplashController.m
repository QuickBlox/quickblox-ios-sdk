//
//  SplashController.m
//  SimpleSample-chat_users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SplashController.h"

#import "AppDelegate.h"

@implementation SplashController
@synthesize wheel = _wheel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload{
    self.wheel = nil;

    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // QuickBlox application authorization
    [QBAuthService authorizeAppId:appID key:authKey secret:authSecret delegate:self];
}

- (void)hideSplash
{
    [self presentModalViewController:[[[ChatViewController alloc] init] autorelease] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark ActionStatusDelegate

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
            [self processErrors:result.errors];
        }
    }
}

// Show errors
-(void)processErrors:(NSArray *)errors{
	NSMutableString *errorsString = [NSMutableString stringWithCapacity:0];
	
	for(NSString *error in errors){
		[errorsString appendFormat:@"%@\n", error];
	}
	
	if ([errorsString length] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "") 
                                                        message:errorsString 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", "") 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
	}
}

@end