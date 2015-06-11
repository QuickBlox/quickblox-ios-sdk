//
//  OperationsViewController.m
//  sample-users
//
//  Created by Igor Khomenko on 6/11/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "OperationsViewController.h"
#import "SignInSignUpViewController.h"
#import "UserDetailsViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface OperationsViewController ()

@property (nonatomic) IBOutlet UIButton *signInButton;
@property (nonatomic) IBOutlet UIButton *signUpButton;
@property (nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation OperationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if([QBSession currentSession].currentUser == nil){
        self.logoutButton.enabled = NO;
        self.editButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender{
    [SVProgressHUD showWithStatus:@"Logout user"];
    
    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        [SVProgressHUD  dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];
        NSLog(@"Response error %@:", response.error);
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if(sender.tag == 201 || sender.tag == 202){
        SignInSignUpViewController *destinationViewController = (SignInSignUpViewController *)segue.destinationViewController;
        destinationViewController.isTypeSignIn = sender.tag == 201;
    }else{
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.user = [QBSession currentSession].currentUser;
    }
}

@end
