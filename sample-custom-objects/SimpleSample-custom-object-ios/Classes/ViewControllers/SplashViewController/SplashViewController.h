//
//  SplashViewController.h
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
// This class creates QuickBlox session in order to use QuickBlox API.
// Then hides splash screen & show main controller that shows how to work
// with QuickBlox Custom Objects module (in particular, how to create & save custom object, edit it,
// how to retrieve all objects.
//
// Note, that in order to use QuickBlox Custom Objects API you must create
// custom object's structure at admin.quickblox.com, Custom Object module

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController <QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activitiIndicator;

@end
