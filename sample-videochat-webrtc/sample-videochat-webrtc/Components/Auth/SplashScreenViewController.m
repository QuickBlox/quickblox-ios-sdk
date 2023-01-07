//
//  SplashScreenViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 08.10.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import "SplashScreenViewController.h"

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

@end
