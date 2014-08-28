//
//  SplashViewController.h
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class creates QuickBlox session in order to use QuickBlox API.
// Then hides splash screen & show main controller that shows how to work
// with QuickBlox Ratings module (in particular, how rate any items (movies, products, music,...)
// and how to see average ratings.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController<QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) id delegate;

-(void)hideSplashScreen;

@end
