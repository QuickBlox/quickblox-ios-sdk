//
//  SplashViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"

@interface SplashViewController ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *wheel;

@end

@implementation SplashViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        [[QBSession currentSession] startSessionWithDetails:session exparationDate:[DateTimeHelper dateFromQBTokenHeader:response.headers[@"QB-Token-ExpirationDate"]]];
        
        QBLGeoDataFilter* filter = [QBLGeoDataFilter new];
        filter.lastOnly = YES;
        filter.sortBy = GeoDataSortByKindCreatedAt;
        
        [QBRequest geoDataWithFilter:filter page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:70]
                        successBlock:^(QBResponse *response, NSArray *objects, QBGeneralResponsePage *page) {
                            [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
                            [DataManager instance].checkinArray = objects;
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Error = %@", response.error);
        }];
        
    } errorBlock:^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)hideSplash
{
    AppDelegate* myDelegate = (((AppDelegate *)[UIApplication sharedApplication].delegate));
    
    [self presentViewController:myDelegate.tabBarController animated:YES completion:nil];
}

@end