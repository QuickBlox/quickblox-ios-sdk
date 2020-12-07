//
//  SplashScreenVC.m
//  sample-push-notifications
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SplashScreenVC.h"
#import "Profile.h"
#import "AppDelegate.h"
#import "RootParentVC.h"

NSString *const DEFAULT_PASSWORD = @"quickblox";

@interface SplashScreenVC ()
//MARK: - Properties
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;

@end

@implementation SplashScreenVC
//MARK: - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    Profile *profile = [[Profile alloc] init];
    if (!profile.isFull) {
        [self.rootParentVC showLoginScreen];
    } else {
        [self loginWithFullName:profile.fullName login:profile.login password:profile.password];
    }
}

#pragma mark - Internal Methods
/**
 *  login
 */
- (void)loginWithFullName:(NSString *)fullName login:(NSString *)login password:(NSString *)password {
    
    self.loginInfoLabel.text = @"Login with current user ...";
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:login
                         password:password
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        [user setPassword:password];
        [Profile synchronizeUser:user];
        [strongSelf.rootParentVC showPushesScreen];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.rootParentVC showLoginScreen];
    }];
}

#pragma mark - RootParentVC
- (RootParentVC*)rootParentVC {
    return (RootParentVC *)[[UIApplication sharedApplication] delegate].window.rootViewController;
}

@end
