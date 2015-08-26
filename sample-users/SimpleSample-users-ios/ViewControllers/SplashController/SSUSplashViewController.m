//
//  SplashViewController.m
//  SimpleSample-users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SSUSplashViewController.h"
#import "SSUMainViewController.h"

@interface SSUSplashViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSUSplashViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Your app connects to QuickBlox server here.
    //
    // QuickBlox session creation
    
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
}

- (void)hideSplash
{
    [self performSegueWithIdentifier:@"MainViewControllerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.activityIndicator stopAnimating];
}

@end