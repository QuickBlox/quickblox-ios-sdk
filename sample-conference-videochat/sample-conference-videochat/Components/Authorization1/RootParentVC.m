//
//  RootParentVC.m
//  samplechat
//
//  Created by Vladimir Nybozhinsky on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "RootParentVC.h"
#import "SplashScreenVC.h"
#import "DialogsViewController.h"
#import "UIColor+Chat.h"
#import "ChatParentVC.h"

@interface DialogsNavigationController: UINavigationController
@end
@implementation DialogsNavigationController
@end

@interface RootParentVC ()
@property (nonatomic, strong) UIViewController *current;
@end

@implementation RootParentVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
        SplashScreenVC *splashScreenVC = [storyboard instantiateViewControllerWithIdentifier:@"SplashScreenVC"];
        self.current = splashScreenVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.current];
    self.current.view.frame = self.view.bounds;
    [self.view addSubview:self.current.view];
    [self.current didMoveToParentViewController:self];
}

- (void)setDialogID:(NSString *)dialogID {
    _dialogID = dialogID;
    [self handlePush];
}

- (void)handlePush {
    if ([self.current isKindOfClass:[DialogsNavigationController class]] && self.dialogID) {
        DialogsNavigationController *dialogsNavigationController = (DialogsNavigationController *)self.current;
        
        self.dialogID = nil;
        
        NSMutableArray *newStack = [NSMutableArray array];
        NSArray *controllers = dialogsNavigationController.viewControllers;
        
        //change stack by replacing view controllers after CallViewController
        for (UIViewController *controller in controllers) {
            [newStack addObject:controller];
            
            if ([controller isKindOfClass:[DialogsViewController class]]) {
                [controller dismissViewControllerAnimated:NO completion:nil];
                NSArray *newControllers = [newStack copy];
                [dialogsNavigationController setViewControllers:newControllers];
                
                break;
            }
        }
        [dialogsNavigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    UINavigationController *new = [storyboard instantiateViewControllerWithIdentifier:@"AuthNavVC"];
    
    [self addChildViewController:new];
    new.view.frame = self.view.bounds;
    [self.view addSubview:new.view];
    [new didMoveToParentViewController:self];
    
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    self.current = new;
}

- (void)switchToDialogsScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsViewController *dialogsScreen = [storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    
    DialogsNavigationController *new = [[DialogsNavigationController alloc] initWithRootViewController:dialogsScreen];
    new.navigationBar.barTintColor = [UIColor mainColor];
    new.navigationBar.barStyle = UIBarStyleBlack;
    new.navigationBar.shadowImage = UIImage.new;
    [new.navigationBar setTranslucent:NO];
    new.navigationBar.tintColor = UIColor.whiteColor;
    new.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    
    [self addChildViewController:new];
    new.view.frame = self.view.bounds;
    [self.view addSubview:new.view];
    [new didMoveToParentViewController:self];
    
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    self.current = new;
    
    [self handlePush];
}

- (void)animateFadeTransitionToNew:(UIViewController *)new
                        completion: (nullable void(^)(void))completion {
    
    [self addChildViewController:new];
    [new didMoveToParentViewController:self];
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    
    self.current = new;
    if (completion) {
        completion();
    }
}

- (void)animateDismissTransitionToNew:(UIViewController *)new
                           completion: (nullable void(^)(void))completion {
    
    CGRect initialFrame = CGRectMake(-self.view.bounds.size.width, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.current willMoveToParentViewController:nil];
    [self addChildViewController:new];
    new.view.frame = initialFrame;
    
    [self.current removeFromParentViewController];
    [new didMoveToParentViewController:self];
    self.current = new;
    if (completion) {
        completion();
    }
  }

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
