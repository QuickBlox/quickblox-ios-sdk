//
//  SplashViewController.m
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSCSplashViewController.h"
#import "SSCMainViewController.h"

@interface SSCSplashViewController () <QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SSCSplashViewController

- (void(^)(QBResponse *, QBASession *))sessionSuccessBlock
{
    return ^(QBResponse *response, QBASession *session) {
        [[QBSession currentSession] startSessionWithDetails:session exparationDate:[DateTimeHelper dateFromQBTokenHeader:response.headers[@"QB-Token-ExpirationDate"]]];
        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
        [pagedRequest setPerPage:20];
        
        [QBContent blobsWithPagedRequest:pagedRequest delegate:self];
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    
    // Your app connects to QuickBlox server here.
    
    QBSessionParameters *parameters = [QBSessionParameters new];
    parameters.userLogin = @"quickbloxUser1";
    parameters.userPassword = @"quickbloxUser1";
    
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


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result
{
    if ([result isKindOfClass:[QBCBlobPagedResult class]]){
        // Success result
        if(result.success){
            QBCBlobPagedResult *res = (QBCBlobPagedResult *)result; 
            
            // Save user's filelist
            [DataManager instance].fileList = [res.blobs mutableCopy];
            
            // hid splash screen
            [self performSelector:@selector(hideSplashScreen) withObject:self afterDelay:1];
        }
    }
}


@end
