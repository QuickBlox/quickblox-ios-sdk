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
    
    // QuickBlox session creation
    __weak typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:@"qbuser321" password:@"qbuser321" successBlock:^(QBResponse *response, QBUUser *user) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf registerForRemoteNotifications];
        [strongSelf.wheel stopAnimating];
        [strongSelf hideSplash];
    } errorBlock:[self handleError]];
}

/// solution for iOS 6.0+
- (void)registerForRemoteNotifications{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}

- (void)hideSplash
{
    [self.navigationController pushViewController:[SSMMainViewController new] animated:YES];
}

@end