//
//  SelectedUsersCountAlert.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 04.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "SelectedUsersCountAlert.h"
#import "PaddingLabel.h"
#import "UIView+Videochat.h"

@interface SelectedUsersCountAlert ()
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet PaddingLabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@end

@implementation SelectedUsersCountAlert
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

//MARK: - Actions
- (IBAction)tapCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

//MARK: - Private Methods
- (void)setupViews {
    [self.alertLabel setupTextPaddingInsets: UIEdgeInsetsMake(0.0f, 11.0f, 0.0f, 0.0f)];
    [self.alertLabel setRoundViewWithCornerRadius:3.0f];
    [self.alertView addShadow:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    
    CGFloat topBarHeight = self.view.window.windowScene.statusBarManager.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    self.alertView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.alertView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:12.0f].active = YES;
    [self.alertView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:112.0f + topBarHeight].active = YES;
    [self.alertView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-12.0f].active = YES;
    [self.alertView.heightAnchor constraintEqualToConstant:44.0f].active = YES;
}

@end
