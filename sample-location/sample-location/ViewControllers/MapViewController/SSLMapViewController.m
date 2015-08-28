//
//  MapViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSLMapViewController.h"
#import "SSLMapPin.h"
#import "SSLDataManager.h"
#import "SSLGeoDataManager.h"
#import "SSLAuthViewController.h"

@interface SSLMapViewController () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end

@implementation SSLMapViewController

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMapAnnotations) name:SSLGeoDataManagerDidUpdateData object:nil];
    
    [self updateMapAnnotations];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = [segue destinationViewController];
    SSLAuthViewController *authViewController = (SSLAuthViewController *)[navigationController topViewController];
    
    if ([segue.identifier isEqualToString:@"signUpAction"]) {
        authViewController.mode = SSLAuthViewControllerModeSignUp;
        
    } else if ([segue.identifier isEqualToString:@"logInAction"]) {
        authViewController.mode = SSLAuthViewControllerModeLogIn;
    }
}

#pragma mark - User Actions

- (IBAction)checkIn:(id)sender
{
    // Show alert if user did not logged in
    if([SSLDataManager instance].currentUser == nil) {
        [self showNeedAuthorizeAlertView];
        
    // Show alert for check in
    } else {
        [self showCheckInCommentAlertView];
    }
}

#pragma mark - Actions

- (void)updateMapAnnotations {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for(QBLGeoData *geodata in [SSLDataManager instance].checkins) {
        
        CLLocationCoordinate2D coord = {.latitude = geodata.latitude, .longitude = geodata.longitude};
        
        SSLMapPin *pin = [[SSLMapPin alloc] initWithCoordinate:coord];
        pin.subtitle = geodata.status;
        pin.title = geodata.user.login ? geodata.user.login : geodata.user.email;
        
        [self.mapView addAnnotation:pin];
    }
}

- (void)showNeedAuthorizeAlertView {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You must first be authorized."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Sign Up", @"Sign In", nil];
    
    [alertView show];
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
        
        [[SSLGeoDataManager instance] fetchLatestCheckIns];
        
    } errorBlock:^(QBResponse *response) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in wasn't successful"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }];
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
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        
        [self checkInCommentAlertView:alertView clickedButtonAtIndex:buttonIndex];
        
    } else {
        
        [self authorizationAlertViewClickedButtonAtIndex:buttonIndex];
    }
}

- (void)authorizationAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            return;
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"signUpAction" sender:nil];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"logInAction" sender:nil];
            break;
            
        default:
            break;
    }
}

- (void)checkInCommentAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            return;
            break;
            
        case 1:
            [self saveCheckInWithComment:[alertView textFieldAtIndex:0].text];
            break;
            
        default:
            break;
    }
}


@end
