//
//  SplashViewController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCSplashViewController.h"
#import "SSCMainViewController.h"

@interface SSCSplashViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSCSplashViewController

- (void(^)(QBResponse *, QBASession *))sessionSuccessBlock
{
    return ^(QBResponse *response, QBASession *session) {
        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:20];
        [QBRequest blobsForPage:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
            
            [[SSCContentManager instance] saveFileList:blobs];
            
            // hide splash screen
            [self performSelector:@selector(hideSplashScreen) withObject:self afterDelay:1];
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
        }];
        
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    
    // Your app connects to QuickBlox server here.
    
    QBSessionParameters *parameters = [QBSessionParameters new];
    parameters.userLogin = @"igorquickblox";
    parameters.userPassword = @"igorquickblox";
    
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:[self sessionSuccessBlock]
                                        errorBlock:^(QBResponse *response) {
                                            NSLog(@"Response error %@:", response.error);
                                        }];
}

- (void)hideSplashScreen
{
    [self.activityIndicator stopAnimating];
    [self.navigationController pushViewController:[SSCMainViewController new] animated:YES];
}

@end