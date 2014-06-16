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

@interface SSLMapViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIViewController *loginController;
@property (nonatomic, strong) IBOutlet UIViewController *registrationController;

@end

@implementation SSLMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Map", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"globe.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([self.mapView.annotations count] <= 1) {
        for(QBLGeoData *geodata in [SSLDataManager instance].checkins) {
            CLLocationCoordinate2D coord = {.latitude = geodata.latitude, .longitude = geodata.longitude};
            SSLMapPin *pin = [[SSLMapPin alloc] initWithCoordinate:coord];
            pin.subtitle = geodata.status;
            pin.title = geodata.user.login ? geodata.user.login : geodata.user.email;
            [self.mapView addAnnotation:pin];
        }
    }
}

// Show checkin view
- (IBAction)checkIn:(id)sender
{
    // Show alert if user did not logged in
    
    if([SSLDataManager instance].currentUser == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must first be authorized."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Sign Up", @"Sign In", nil];
        alert.tag = 1;
        [alert show];
    // Show alert for check in
    } else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your message"
                                                        message:@"\n"
                                                       delegate:self
                                              cancelButtonTitle:@"Canсel"
                                              otherButtonTitles:@"Check In", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 2;
        [alert show];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // User didn't auth  alert
    if(alertView.tag == 1) {
        switch (buttonIndex) {
            case 1:
                [self presentViewController:self.registrationController animated:YES completion:nil];
                break;
            case 2:
                [self presentViewController:self.loginController animated:YES completion:nil];
                break;
            default:
                break;
        }
        
    // Check in   alert
    }else if(alertView.tag == 2) {
        switch (buttonIndex) {
            case 1: {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
                // Check in
                //
                // create QBLGeoData entity
                QBLGeoData *geoData = [QBLGeoData geoData];
                geoData.latitude = self.locationManager.location.coordinate.latitude;
                geoData.longitude = self.locationManager.location.coordinate.longitude;
                geoData.status = [alertView textFieldAtIndex:0].text;
                
                // post own location
                [QBRequest createGeoData:geoData successBlock:^(QBResponse *response, QBLGeoData *geoData) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in was successful!"
                                                                    message:[NSString stringWithFormat:@"Your coordinates: \n Latitude: %g \n Longitude: %g",geoData.latitude, geoData.longitude]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                    [alert show];
                } errorBlock:^(QBResponse *response) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in wasn't successful"
                                                                    message:[response.error description]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                    [alert show];
                }];
                
                break;
            }
            default:
                break;
        }
    }
}


@end
