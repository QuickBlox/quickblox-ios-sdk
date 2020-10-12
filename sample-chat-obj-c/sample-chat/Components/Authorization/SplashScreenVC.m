//
//  SplashScreenVC.m
//  samplechat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SplashScreenVC.h"
#import "Profile.h"
#import "Reachability.h"
#import "Log.h"
#import "AppDelegate.h"
#import "RootParentVC.h"

NSString *const DEFAULT_PASSWORD = @"quickblox";

@interface SplashScreenVC ()
//MARK: - Properties
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;

@end

@implementation SplashScreenVC
//MARK: - Life Cycle
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
    void (^updateLoginInfo)(NetworkStatus status) = ^(NetworkStatus status) {
        
        NSString *loginInfo = (status == NetworkStatusNotReachable) ?
        NSLocalizedString(@"Please check your Internet connection", nil):
        NSLocalizedString(@"Login into chat ...", nil);
        [self updateLoginInfoText:loginInfo];
        
        Profile *profile = [[Profile alloc] init];
        if (profile.isFull && status != NetworkStatusNotReachable) {
            [self loginWithFullName:profile.fullName login:profile.login password:profile.password];
        }
    };
    
    Reachability.instance.networkStatusBlock = ^(NetworkStatus status) {
        updateLoginInfo(status);
    };
    
    updateLoginInfo(Reachability.instance.networkStatus);
}

#pragma mark - Internal Methods
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
    
    [self updateLoginInfoText:@"Login into chat ..."];
    
    __weak __typeof(self)weakSelf = self;
    
    if ([QBChat.instance isConnected]) {
        //did Login action
        dispatch_async(dispatch_get_main_queue(), ^{
            [(RootParentVC *)[self shared].window.rootViewController showDialogsScreen];
        });
    } else {
        
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(RootParentVC *)[strongSelf shared].window.rootViewController showDialogsScreen];
                });
            }
        }];
    }
}

#pragma mark - Helpers    
- (void)updateLoginInfoText:(NSString *)text {
    if ([text isEqualToString:self.loginInfoLabel.text] == NO) {
        self.loginInfoLabel.text = text;
    }
}

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
