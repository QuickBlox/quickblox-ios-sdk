//
//  SplashScreenVC.m
//  sample-chat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "Profile.h"
#import "UIViewController+Alert.h"

@interface SplashScreenViewController () <QBChatDelegate>
//MARK: - Properties
@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
@property (assign, nonatomic) BOOL isPresentAlert;
@end

@implementation SplashScreenViewController
//MARK: - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    Profile *profile = [[Profile alloc] init];
    if (!profile.isFull && self.onCompleteAuth) {
        self.onCompleteAuth(NO);
        return;
    }
    self.isPresentAlert = NO;
    [QBChat.instance addDelegate:self];
    [self connectToChat:profile.ID];
}

#pragma mark - Internal Methods
- (void)connectToChat:(NSUInteger)userID {
    [self updateLoginInfoText:@"Login into chat ..."];
    __weak __typeof(self)weakSelf = self;
    [QBChat.instance connectWithUserID:userID
                              password:@"quickblox"
                            completion:^(NSError * _Nullable error) {
        if (error && error.code == QBResponseStatusCodeUnAuthorized) {
            [Profile clear];
            weakSelf.onCompleteAuth(NO);
            return;
        }
        //did Login action
        if (weakSelf.onCompleteAuth) {
            weakSelf.onCompleteAuth(YES);
        }
    }];
}

#pragma mark - Helpers
- (void)updateLoginInfoText:(NSString *)text {
    if ([text isEqualToString:self.loginInfoLabel.text] == NO) {
        self.loginInfoLabel.text = text;
    }
}

- (void)chatDidDisconnectWithError:(NSError *)error {
    if (self.isPresentAlert == YES || error == nil || error.code != 8) {
        return;
    }
    [self updateLoginInfoText: @"Please check your Internet connection"];
    self.isPresentAlert = YES;
    __weak __typeof(self)weakSelf = self;
    [self showNoInternetAlertWithHandler:^(UIAlertAction * _Nonnull action) {
        Profile *profile = [[Profile alloc] init];
        [weakSelf connectToChat:profile.ID];
        weakSelf.isPresentAlert = NO;
    }];
}

@end
