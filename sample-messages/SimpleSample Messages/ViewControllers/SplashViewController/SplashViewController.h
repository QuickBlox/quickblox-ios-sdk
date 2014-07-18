//
//  SplashViewController.h
//  SimpleSample-messages_users-ios
//
//  Created by Danil on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//
//
// This class creates QuickBlox session in order to use QuickBlox API.
// Then hides splash screen & show main controller that shows how to work
// with QuickBlox Messages module (in particular, how to use Push Notifications through QuickBlox)
//

#import "MainViewController.h"

@class MainViewController;

@interface SplashViewController : UIViewController <QBActionStatusDelegate>{
}
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *wheel;

- (void)hideSplash;

@end