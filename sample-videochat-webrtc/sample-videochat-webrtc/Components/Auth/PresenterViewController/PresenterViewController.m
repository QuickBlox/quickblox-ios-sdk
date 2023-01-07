//
//  RootParentVC.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "PresenterViewController.h"
#import "UsersViewController.h"
#import "AuthorizationViewController.h"
#import "UINavigationController+Appearance.h"
#import "Profile.h"

@interface PresenterViewController ()
//MARK: - Properties
@property (nonatomic, strong) UIViewController *current;
@end

@implementation PresenterViewController
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Profile *profile = [[Profile alloc] init];
    profile.isFull ? [self showUsersScreen] : [self showLoginScreen];
}

// MARK: - Internal Methods
- (void)showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    AuthorizationViewController *authorizationVC = [storyboard instantiateViewControllerWithIdentifier:@"AuthorizationViewController"];
    UINavigationController *authNavVC = [[UINavigationController alloc] initWithRootViewController:authorizationVC];
    [authNavVC setupAppearanceWithColor:nil titleColor:UIColor.whiteColor];
    [authorizationVC setOnCompleteAuth:^(void) {
        [self showUsersScreen];
    }];
    if (self.current == nil) {
        self.current = authNavVC;
    }
    [self changeCurrentViewController:authNavVC];
}

- (void)showUsersScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    UsersViewController *usersScreen = [storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];
    UINavigationController *usersNavVC = [[UINavigationController alloc] initWithRootViewController:usersScreen];
    [usersNavVC setupAppearanceWithColor:nil titleColor:UIColor.whiteColor];
    [usersScreen setOnSignOut:^{
        [self showLoginScreen];
    }];
    if (self.current == nil) {
        self.current = usersNavVC;
    }
    [self changeCurrentViewController:usersNavVC];
}

//MARK - Setup
- (void)changeCurrentViewController:(UIViewController *)new {
    [self addChildViewController:new];
    new.view.frame = self.view.bounds;
    [self.view addSubview:new.view];
    [new didMoveToParentViewController:self];
    
    if ([self.current isEqual:new]) {
        return;
    }
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    self.current = new;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
