//
//  SplashViewController.m
//  SimpleSample-users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *wheel;

@end

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
    
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        [[QBSession currentSession] startSessionWithDetails:session exparationDate:[DateTimeHelper dateFromQBTokenHeader:response.headers[@"QB-Token-ExpirationDate"]]];
        [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
    } errorBlock:^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)hideSplash
{
    [self presentViewController:[MainViewController new] animated:YES completion:nil];
}

@end