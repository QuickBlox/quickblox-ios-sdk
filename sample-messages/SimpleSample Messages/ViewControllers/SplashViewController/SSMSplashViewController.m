//
//  SplashViewController.m
//  SimpleSample-messages_users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSMSplashViewController.h"
#import "SSMMainViewController.h"

@interface SSMSplashViewController ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *wheel;

@end

@implementation SSMSplashViewController

- (void(^)(QBResponse *))handleError
{
    return ^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
    };
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Create extended session request (for push notifications)
    QBSessionParameters *parameters = [QBSessionParameters new];
    parameters.userLogin = @"injoitUser1";
    parameters.userPassword = @"injoitUser1";
    
    // QuickBlox session creation
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        [self.wheel stopAnimating];
    } errorBlock:[self handleError]];
}

- (void)hideSplash
{
    [self presentViewController:[SSMMainViewController new] animated:YES completion:nil];
}

@end