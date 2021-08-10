//
//  SplashScreenVC.m
//  sample-conference-videochat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SplashScreenVC.h"

@interface SplashScreenVC ()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
@end

@implementation SplashScreenVC

//MARK: - Public Methods
- (void)setupInfoLabelText:(NSString *)text {
    self.loginInfoLabel.text = text;
}

@end
