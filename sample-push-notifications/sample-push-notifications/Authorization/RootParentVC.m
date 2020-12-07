//
//  RootParentVC.m
//  sample-push-notifications
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "RootParentVC.h"
#import "SplashScreenVC.h"
#import "PushViewController.h"
#import "UIColor+Chat.h"

@interface PushesNavigationController: UINavigationController
@end
@implementation PushesNavigationController
@end

@interface RootParentVC ()
//MARK: - Properties
@property (nonatomic, strong) UIViewController *current;
@end

@implementation RootParentVC
//MARK: - Life Cycle
- (instancetype)init {
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

    [self setupChildViewController:self.current];
}

//MARK - Setup
- (void)setupChildViewController:(UIViewController *)new {
    
    if ([self.current isEqual:new]) {
        [self addChildViewController:new];
        new.view.frame = self.view.bounds;
        [self.view addSubview:new.view];
        [new didMoveToParentViewController:self];

    } else {
        [self addChildViewController:new];
        new.view.frame = self.view.bounds;
        [self.view addSubview:new.view];
        [new didMoveToParentViewController:self];
        
        [self.current willMoveToParentViewController:nil];
        [self.current.view removeFromSuperview];
        [self.current removeFromParentViewController];
        self.current = new;
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// MARK: - Public Methods
- (void)showLoginScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authorization" bundle:nil];
    UINavigationController *new = [storyboard instantiateViewControllerWithIdentifier:@"AuthNavVC"];
    
    [self setupChildViewController:new];
}

- (void)showPushesScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PushViewController *pushViewController = [storyboard instantiateViewControllerWithIdentifier:@"PushViewController"];
    
    PushesNavigationController *new = [[PushesNavigationController alloc] initWithRootViewController:pushViewController];
    new.navigationBar.barTintColor = [UIColor mainColor];
    new.navigationBar.barStyle = UIBarStyleBlack;
    new.navigationBar.shadowImage = UIImage.new;
    [new.navigationBar setTranslucent:NO];
    new.navigationBar.tintColor = UIColor.whiteColor;
    new.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    
    [self setupChildViewController:new];
    
}

@end
