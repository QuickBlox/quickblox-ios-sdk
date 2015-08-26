//
//  SplashViewController.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCOSplashViewController.h"
#import "SSCOMainViewController.h"

@interface SSCOSplashViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activitiIndicator;

@end

@implementation SSCOSplashViewController

- (void(^)(QBResponse *response, QBUUser *user))sessionSuccessBlock
{
    return ^(QBResponse *response, QBUUser *user) {
        [QBRequest objectsWithClassName:customClassName
                           successBlock:^(QBResponse *response, NSArray *objects) {
                               [[SSCONotesStorage shared] addNotes:objects];
                               [self performSelector:@selector(hideSplashScreen) withObject:self afterDelay:2];
                           } errorBlock:[self handleErrorBlock]];
    };
}

- (void(^)(QBResponse *))handleErrorBlock
{
    return ^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.activitiIndicator startAnimating];
    
    QBSessionParameters *parameters = [QBSessionParameters new];
    parameters.userLogin = @"injoitUser1";
    parameters.userPassword = @"injoitUser1";
    
    [QBRequest logInWithUserLogin:@"injoitUser1" password:@"injoitUser1" successBlock:[self sessionSuccessBlock] errorBlock:[self handleErrorBlock]];
}

- (void)hideSplashScreen
{
    [self.navigationController pushViewController:[SSCOMainViewController new] animated:YES];
}

@end
