//
//  SplashViewController.h
//  SimpleSample-Content
//
//  Created by kirill on 7/17/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class creates QuickBlox session in order to use QuickBlox API.
// Then retrieves user's filelist.
// Then hides splash screen & show main controller that shows how to work
// with QuickBlox Content module (in particular, how to organize user's gallery, download\upload images to it)
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController<QBActionStatusDelegate>

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
