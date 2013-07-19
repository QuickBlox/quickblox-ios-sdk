//
//  SplashViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize activitiIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.activitiIndicator startAnimating];
    
    // QuickBlox application authorization
    QBASessionCreationRequest *extendedAuthRequest = [[QBASessionCreationRequest alloc] init];
    extendedAuthRequest.userLogin = @"injoitUser1";
    extendedAuthRequest.userPassword = @"injoitUser1";
    
    [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
    
    [extendedAuthRequest release];
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.activitiIndicator.frame;
        frame.origin.y += 44;
        [self.activitiIndicator setFrame:frame];
    }
}

- (void)viewDidUnload
{
    [self setActivitiIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [activitiIndicator release];
    [super dealloc];
}

-(void)hideSplashScreen{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result{
    // QuickBlox session creation result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){
            
            // Get all notes
            [QBCustomObjects objectsWithClassName:customClassName delegate:self];
        }
        
    // Get all notes result
    } else if([result isKindOfClass:QBCOCustomObjectPagedResult.class]){
        
        // Success result
        if(result.success){

            // save all notes
            QBCOCustomObjectPagedResult *res = (QBCOCustomObjectPagedResult *)result;
            [[[DataManager shared] notes] addObjectsFromArray:res.objects];
            
            // hide splash
            [self performSelector:@selector(hideSplashScreen) withObject:self afterDelay:2];
        }
    }
}

@end
