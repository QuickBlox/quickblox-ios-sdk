//
//  SplashScreenVC.m
//  samplechat
//
//  Created by Vladimir Nybozhinsky on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SplashScreenVC.h"
#import "Profile.h"
#import "Reachability.h"
#import "Log.h"
#import "AppDelegate.h"
#import "RootParentVC.h"
//#import <UserNotifications/UserNotifications.h>

NSString *const DEFAULT_PASSWORD = @"quickblox";

@interface SplashScreenVC ()
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;

@end

@implementation SplashScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Profile *profile = [[Profile alloc] init];
    if (!profile.isFull) {
        [(RootParentVC *)[self shared].window.rootViewController showLoginScreen];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Reachability
    void (^updateLoginInfo)(QBNetworkStatus status) = ^(QBNetworkStatus status) {
        
        NSString *loginInfo = (status == QBNetworkStatusNotReachable) ?
        NSLocalizedString(@"Please check your Internet connection", nil):
        NSLocalizedString(@"Login into conference ...", nil);
        [self updateLoginInfoText:loginInfo];
        
        Profile *profile = [[Profile alloc] init];
        if (profile.isFull && status != QBNetworkStatusNotReachable) {
            [self loginWithFullName:profile.fullName login:profile.login password:profile.password];
        }
    };
    
    Reachability.instance.networkStatusBlock = ^(QBNetworkStatus status) {
        updateLoginInfo(status);
    };
    
    updateLoginInfo(Reachability.instance.networkStatus);
}

/**
 *  login
 */
- (void)loginWithFullName:(NSString *)fullName login:(NSString *)login password:(NSString *)password {
    [self updateLoginInfoText:@"Login with current user ..."];
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:login
                         password:password
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [user setPassword:password];
        [Profile synchronizeUser:user];
        [strongSelf connectToChat:user];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"response.error.error %@", response.error.error);
        [strongSelf handleError:response.error.error];
        if (response.status == QBResponseStatusCodeUnAuthorized) {
            // Clean profile
            [Profile clearProfile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [(RootParentVC *)[self shared].window.rootViewController showLoginScreen];
            });
        }
    }];
}

/**
 *  connectToChat
 */
- (void)connectToChat:(QBUUser *)user {
    
    [self updateLoginInfoText:@"Login into conference ..."];
    
    __weak __typeof(self)weakSelf = self;
    
    [QBChat.instance connectWithUserID:user.ID
                              password:DEFAULT_PASSWORD
                            completion:^(NSError * _Nullable error) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error) {
            if (error.code == QBResponseStatusCodeUnAuthorized) {
                // Clean profile
                [Profile clearProfile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(RootParentVC *)[self shared].window.rootViewController showLoginScreen];
                });
                
            } else {
                [strongSelf handleError:error];
            }
        } else {
            //did Login action
//            [strongSelf registerForRemoteNotifications];
            dispatch_async(dispatch_get_main_queue(), ^{
                [(RootParentVC *)[strongSelf shared].window.rootViewController switchToDialogsScreen];
            });
        }
    }];
}

- (void)updateLoginInfoText:(NSString *)text {
    if ([text isEqualToString:self.loginInfoLabel.text] == NO) {
        self.loginInfoLabel.text = text;
    }
}

//- (void)registerForRemoteNotifications {
//    // Enable push notifications
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//
//    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound |
//                                             UNAuthorizationOptionAlert |
//                                             UNAuthorizationOptionBadge)
//                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (error) {
//            Log(@"%@ registerForRemoteNotifications error: %@",NSStringFromClass([SplashScreenVC class]),
//                error.localizedDescription);
//            return;
//        }
//        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
//            if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
//                return;
//            }
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[UIApplication sharedApplication] registerForRemoteNotifications];
//            });
//        }];
//    }];
//}

- (AppDelegate*)shared {
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

#pragma mark - Handle errors
- (void)handleError:(NSError *)error {
    NSString *infoText = error.localizedDescription;
    if (error.code == NSURLErrorNotConnectedToInternet) {
        infoText = NSLocalizedString(@"Please check your Internet connection", nil);
    }
    [self updateLoginInfoText: infoText];
}

@end
