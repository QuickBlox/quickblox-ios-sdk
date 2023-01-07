//
//  RootParentVC.m
//  sample-chat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "PresenterViewController.h"
#import "UIColor+Chat.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "AuthorizationViewController.h"
#import "NotificationsProvider.h"
#import "UINavigationController+Appearance.h"
#import "Profile.h"

@interface PresenterViewController ()<NotificationsProviderDelegate>
//MARK: - Properties
@property (nonatomic, strong) UIViewController *current;
@property (nonatomic, strong) NotificationsProvider *notificationsProvider;
@end

@implementation PresenterViewController
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    Profile *profile = [[Profile alloc] init];
    profile.isFull ? [self showDialogsScreen] : [self showLoginScreen];
    
    self.notificationsProvider = [[NotificationsProvider alloc] init];
    self.notificationsProvider.delegate = self;
}

// MARK: - Internal Methods
- (void)showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    AuthorizationViewController *authorizationVC = [storyboard instantiateViewControllerWithIdentifier:@"AuthorizationViewController"];
    UINavigationController *authNavVC = [[UINavigationController alloc] initWithRootViewController:authorizationVC];
    [authNavVC setupAppearanceWithColor:nil titleColor:UIColor.whiteColor];
    [authorizationVC setOnCompleteAuth:^(void) {
        [self showDialogsScreen];
    }];
    if (self.current == nil) {
        self.current = authNavVC;
    }
    [self changeCurrentViewController:authNavVC];
}

- (void)showDialogsScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsViewController *dialogsScreen = [storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    UINavigationController *dialogsNavVC = [[UINavigationController alloc] initWithRootViewController:dialogsScreen];
    [dialogsNavVC setupAppearanceWithColor:nil titleColor:UIColor.whiteColor];
    [dialogsScreen setOnSignOut:^{
        [self showLoginScreen];
    }];
    if (self.current == nil) {
        self.current = dialogsNavVC;
    }
    [self changeCurrentViewController:dialogsNavVC];
    [self.notificationsProvider registerForRemoteNotifications];
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

//MARK: - NotificationsProviderDelegate
- (void)notificationsProvider:(NotificationsProvider *)notificationsProvider didReceive:(NSString *)dialogID {
    if (!dialogID.length) {
            return;
        }
        [self showDialogsScreen];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
