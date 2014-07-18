//
//  MapViewController.h
//  SimpleSample-location_users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to work with QuickBlox Location module.
// It shows users' locations on the map.
// It allows to share own position.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <QBActionStatusDelegate, UIAlertViewDelegate> {
    CLLocationManager* locationManager;
}
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIViewController *loginController;
@property (nonatomic, strong) IBOutlet UIViewController *registrationController;

- (IBAction) checkIn:(id)sender;

@end
