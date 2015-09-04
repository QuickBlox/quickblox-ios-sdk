//
//  MapViewController.m
//  sample-location
//
//  Created by Quickblox Team on 24.02.12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "MapViewController.h"
#import "MapPin.h"
#import "DataManager.h"
#import "GeoDataManager.h"

@interface MapViewController () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;

@end

@implementation MapViewController

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMapAnnotations) name:GeoDataManagerDidUpdateData object:nil];
    
    [self updateMapAnnotations];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self customizeCheckInButton];
}

#pragma mark - UI Customization

- (void)customizeCheckInButton {
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.checkInButton.bounds];
    self.checkInButton.layer.masksToBounds = NO;
    self.checkInButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.checkInButton.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.checkInButton.layer.shadowOpacity = 0.3f;
    self.checkInButton.layer.shadowPath = shadowPath.CGPath;
    
    self.checkInButton.layer.cornerRadius = 5.0f;
    
    self.checkInButton.alpha = 0.8f;
}

#pragma mark - User Actions

- (IBAction)checkIn:(id)sender
{
    [self showCheckInCommentAlertView];
}

#pragma mark - Actions

- (void)updateMapAnnotations {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for(QBLGeoData *geodata in [DataManager instance].checkins) {
        
        CLLocationCoordinate2D coord = {.latitude = geodata.latitude, .longitude = geodata.longitude};
        
        MapPin *pin = [[MapPin alloc] initWithCoordinate:coord];
        pin.subtitle = geodata.status;
        pin.title = geodata.user.login ? geodata.user.login : geodata.user.email;
        
        [self.mapView addAnnotation:pin];
    }
}

- (void)showCheckInCommentAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enter your message"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Canсel"
                                              otherButtonTitles:@"Check In", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

#pragma mark - Network Interaction

- (void)saveCheckInWithComment:(NSString *)comment {
    
    QBLGeoData *geoData = [self createQBGeoDataWithComment:comment];
    
    [QBRequest createGeoData:geoData successBlock:^(QBResponse *response, QBLGeoData *geoData) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in was successful!"
                                                        message:[NSString stringWithFormat:@"Your coordinates: \n Latitude: %g \n Longitude: %g",geoData.latitude, geoData.longitude]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [[GeoDataManager instance] fetchLatestCheckIns];
        
    } errorBlock:^(QBResponse *response) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in wasn't successful"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)checkCurrentUserWithCompletion:(void(^)(NSError *authError))completion {
    
    if ([[QBSession currentSession] currentUser] != nil) {
        
        if (completion) completion(nil);
        
    } else {
        
        [QBRequest logInWithUserLogin:@"injoitUser1" password:@"injoitUser1" successBlock:^(QBResponse *response, QBUUser *user) {
            
            if (completion) completion(nil);
            
        } errorBlock:^(QBResponse *response) {
            
            if (completion) completion(response.error.error);
        }];
    }
}

#pragma mark - Helper

- (QBLGeoData *)createQBGeoDataWithComment:(NSString *)comment {
    
    QBLGeoData *geoData = [QBLGeoData geoData];
    geoData.latitude = self.locationManager.location.coordinate.latitude;
    geoData.longitude = self.locationManager.location.coordinate.longitude;
    geoData.status = comment;
    
    return geoData;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self checkInCommentAlertView:alertView clickedButtonAtIndex:buttonIndex];
}

- (void)checkInCommentAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            return;
            break;
            
        case 1: {
            
            NSString *comment = [alertView textFieldAtIndex:0].text;
            
            [self checkCurrentUserWithCompletion:^(NSError *authError) {
                
                if (authError) {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[authError localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                    
                } else {
                    
                    [self saveCheckInWithComment:comment];
                }
            }];
            
        }
            break;
            
        default:
            break;
    }
}


@end
