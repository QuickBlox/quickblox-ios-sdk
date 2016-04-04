//
//  STKOrientationNavigationController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 19.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKOrientationNavigationController.h"

@interface STKOrientationNavigationController ()

@end

@implementation STKOrientationNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

@end
