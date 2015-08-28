//
//  OperationsViewController.m
//  sample-users
//
//  Created by Quickblox Team on 6/11/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "ActionsViewController.h"
#import "UserDetailsViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface ActionsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *signInButton;
@property (nonatomic, weak) IBOutlet UIButton *signUpButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *logoutButton;

@end

@implementation ActionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([QBSession currentSession].currentUser == nil) {
        self.logoutButton.enabled = NO;
        self.editButton.enabled = NO;
    }
}

- (IBAction)logout:(id)sender
{
    [SVProgressHUD showWithStatus:@"Logout user"];
    
    __weak typeof(self)weakSelf = self;
    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        [SVProgressHUD  dismiss];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];
        NSLog(@"Response error %@:", response.error);
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender
{
    if ([segue.destinationViewController isKindOfClass:UserDetailsViewController.class]) {
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.user = [QBSession currentSession].currentUser;
    }
}

@end
