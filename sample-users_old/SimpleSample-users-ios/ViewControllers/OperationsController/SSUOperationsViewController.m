//
//  SSUOperationsViewController.m
//  SimpleSample-users-ios
//
//  Created by Andrey Moskvin on 7/21/14.
//  Copyright (c) 2014 Injoit. All rights reserved.
//

#import "SSUOperationsViewController.h"
#import "SSULoginState.h"
#import "SSUChangesLoginState.h"

@interface SSUOperationsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (strong, nonatomic) SSULoginState* loginState;

@end

@implementation SSUOperationsViewController

- (SSULoginState *)loginState
{
    if (_loginState == nil) {
        _loginState = [SSULoginState new];
    }
    return _loginState;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshButtons];
}

- (void)refreshButtons
{
    self.editButton.enabled = self.loginState.isLoggedIn;
    self.logoutButton.enabled = self.loginState.isLoggedIn;
}

- (IBAction)logoutButtonTouched:(id)sender
{
    @weakify(self);
    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        @strongify(self);
        self.loginState.isLoggedIn = NO;
        [self refreshButtons];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* destination = segue.destinationViewController;
    if ([destination conformsToProtocol:@protocol(SSUChangesLoginState)]) {
        UIViewController<SSUChangesLoginState>* controller = (UIViewController<SSUChangesLoginState> *)destination;
        
        controller.loginState = self.loginState;
    }
}

@end
