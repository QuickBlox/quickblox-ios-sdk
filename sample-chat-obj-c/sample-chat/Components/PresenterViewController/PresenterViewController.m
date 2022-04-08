//
//  RootParentVC.m
//  sample-chat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "PresenterViewController.h"
#import "SplashScreenViewController.h"
#import "UIColor+Chat.h"
#import "DialogsViewController.h"
#import "ChatViewController.h"
#import "AuthorizationViewController.h"
#import "ChatManager.h"
#import "NotificationsProvider.h"
#import "UINavigationController+Appearance.h"

@interface PresenterViewController ()<NotificationsProviderDelegate>
//MARK: - Properties
@property (nonatomic, strong) UIViewController *current;
@property (nonatomic, strong) NotificationsProvider *notificationsProvider;
@end

@implementation PresenterViewController
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationsProvider = [[NotificationsProvider alloc] init];
    self.notificationsProvider.delegate = self;
    [self showSplashScreen];
}

// MARK: - Internal Methods
- (void)showSplashScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    SplashScreenViewController *splashScreenVC = [storyboard instantiateViewControllerWithIdentifier:@"SplashScreenVC"];
    [splashScreenVC setOnCompleteAuth:^(BOOL isSuccess) {
        if (isSuccess) {
            [self showDialogsScreen];
        } else {
            [self showLoginScreen];
        }
    }];
    self.current = splashScreenVC;
    [self changeCurrentViewController:self.current];
}

- (void)showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    AuthorizationViewController *authorizationVC = [storyboard instantiateViewControllerWithIdentifier:@"AuthorizationViewController"];
    [authorizationVC setOnCompleteAuth:^(void) {
        [self showDialogsScreen];
    }];

    [self changeCurrentViewController:authorizationVC];
}

- (void)showDialogsScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsViewController *dialogsScreen = [storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    [dialogsScreen setOnSignIn:^{
        [self showLoginScreen];
    }];
    [self changeCurrentViewController:dialogsScreen];
    [self.notificationsProvider registerForRemoteNotifications];
}

//MARK - Setup
- (void)changeCurrentViewController:(UIViewController *)newCurrentViewController {
    UIViewController *new = [self.current isEqual:newCurrentViewController] ? newCurrentViewController :
    [[UINavigationController alloc] initWithRootViewController:newCurrentViewController];
    if ([new isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationVC = (UINavigationController *)new;
        [navigationVC setupAppearanceWithColor:nil titleColor:UIColor.whiteColor];
    }
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
