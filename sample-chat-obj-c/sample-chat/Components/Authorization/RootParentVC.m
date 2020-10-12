//
//  RootParentVC.m
//  samplechat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "RootParentVC.h"
#import "SplashScreenVC.h"
#import "DialogsViewController.h"
#import "UIColor+Chat.h"

@interface DialogsNavigationController: UINavigationController
@end
@implementation DialogsNavigationController
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
- (void)setDialogID:(NSString *)dialogID {
    _dialogID = dialogID;
    if (_dialogID) {
        [self handlePush];
    }
}

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

- (void)showDialogsScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Dialogs" bundle:nil];
    DialogsViewController *dialogsScreen = [storyboard instantiateViewControllerWithIdentifier:@"DialogsViewController"];
    
    DialogsNavigationController *new = [[DialogsNavigationController alloc] initWithRootViewController:dialogsScreen];
    new.navigationBar.barTintColor = [UIColor mainColor];
    new.navigationBar.barStyle = UIBarStyleBlack;
    new.navigationBar.shadowImage = UIImage.new;
    [new.navigationBar setTranslucent:NO];
    new.navigationBar.tintColor = UIColor.whiteColor;
    new.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:UIColor.whiteColor};
    
    [self setupChildViewController:new];
    
    [self handlePush];
}

//MARK: - Internal Methods
- (void)handlePush {
    if ([self.current isKindOfClass:[DialogsNavigationController class]] && self.dialogID) {
        DialogsNavigationController *dialogsNavigationController = (DialogsNavigationController *)self.current;
        [dialogsNavigationController popToRootViewControllerAnimated:NO];
        if ([dialogsNavigationController.topViewController isKindOfClass:[DialogsViewController class]]) {
            DialogsViewController *dialogsVC = (DialogsViewController *)dialogsNavigationController.topViewController;
            [dialogsVC openChatWithDialogID: self.dialogID];
            
            self.dialogID = nil;
        }
    }
}

@end
