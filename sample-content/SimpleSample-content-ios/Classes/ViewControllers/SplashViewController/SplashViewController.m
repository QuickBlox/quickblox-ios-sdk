//
//  SplashViewController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"
@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [activityIndicator startAnimating];
    
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
    QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
    extendedAuthRequest.userLogin = @"quickbloxUser1";
    extendedAuthRequest.userPassword = @"quickbloxUser1";
    
    [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
    
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.activityIndicator.frame;
        frame.origin.y += 44;
        [self.activityIndicator setFrame:frame];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)hideSplashScreen{
    [activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result{
    // Success result
    if(result.success){
        
        // QuickBlox session creation  result
        if ([result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
            
            // Success result
            if(result.success){
                
                // send request for getting user's filelist
                PagedRequest *pagedRequest = [[PagedRequest alloc] init];    
                [pagedRequest setPerPage:20];
                
                [QBContent blobsWithPagedRequest:pagedRequest delegate:self];
                
            }
        
        // Get User's files result
        } else if ([result isKindOfClass:[QBCBlobPagedResult class]]){
            
            // Success result
            if(result.success){
                QBCBlobPagedResult *res = (QBCBlobPagedResult *)result; 
                
                // Save user's filelist
                [DataManager instance].fileList = [res.blobs mutableCopy];
                
                // hid splash screen
                [self performSelector:@selector(hideSplashScreen) withObject:self afterDelay:1];
            }
        }
    }
}

@end
