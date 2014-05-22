//
//  MapViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MapViewController.h"
#import "MapPin.h"
#import "DataManager.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;
@synthesize loginController;
@synthesize registrationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Map", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"globe.png"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [CLLocationManager new];
    [locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated{
     // add pins to map
    if([mapView.annotations count] <= 1){
        for(QBLGeoData *geodata in [DataManager shared].checkinArray){
            CLLocationCoordinate2D coord = {.latitude= geodata.latitude, .longitude= geodata.longitude};
            MapPin *pin = [[MapPin alloc] initWithCoordinate:coord];
            pin.subtitle = geodata.status;
            pin.title = geodata.user.login ? geodata.user.login : geodata.user.email;
            [mapView addAnnotation:pin];
            [pin release];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Show checkin view
- (IBAction) checkIn:(id)sender {
    
    // Show alert if user did not logged in
    
    if([DataManager shared].currentUser == nil){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must first be authorized."
                                                        message:nil
                                                        delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Sign Up", @"Sign In", nil];
        alert.tag = 1;
        [alert show];
        [alert release];

    // Show alert for check in
    }else{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your message"
                                                        message:@"\n"
                                                        delegate:self
                                                        cancelButtonTitle:@"Canсel"
                                                        otherButtonTitles:@"Check In", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 2;
        [alert show];
        [alert release];
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result  {
     
     if ([result isKindOfClass:[QBLGeoDataResult class]]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // Success result
        if (result.success){
            QBLGeoDataResult *geoDataRes = (QBLGeoDataResult *)result;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in was successful!"
                                                        message:[NSString stringWithFormat:@"Your coordinates: \n Latitude: %g \n Longitude: %g",geoDataRes.geoData.latitude, geoDataRes.geoData.longitude]
                                                        delegate:self 
                                                        cancelButtonTitle:@"Ok" 
                                                        otherButtonTitles: nil];
            [alert show];
            [alert release];
            
        // Errors
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check in wasn't successful"
                                                        message:[result.errors description]
                                                        delegate:self 
                                                        cancelButtonTitle:@"Ok" 
                                                        otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // User didn't auth  alert
    if(alertView.tag == 1) {
        switch (buttonIndex) {
            case 1:
                [self presentModalViewController:registrationController animated:YES];
                break;
            case 2:
                [self presentModalViewController:loginController animated:YES];
                break;
            default:
                break;
        }
        
    // Check in   alert
    }else if(alertView.tag == 2){
        switch (buttonIndex) {
            case 1:
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
                // Check in
                //
                // create QBLGeoData entity
                QBLGeoData *geoData = [QBLGeoData geoData];
                geoData.latitude = locationManager.location.coordinate.latitude;
                geoData.longitude = locationManager.location.coordinate.longitude;
                geoData.status = [alertView textFieldAtIndex:0].text;
                
                // post own location
                [QBLocation createGeoData:geoData delegate:self];
                
                break;
            default:
                break;
        }
    }
}

- (void)dealloc {
    [locationManager release];
    [mapView release];
    [loginController release];
    [registrationController release];    
    [super dealloc];
}

@end
