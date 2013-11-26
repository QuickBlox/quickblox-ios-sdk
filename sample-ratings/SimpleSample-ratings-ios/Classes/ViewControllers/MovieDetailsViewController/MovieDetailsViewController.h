//
//  MoviDetailsViewController.h
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows movie's details - name, image & rate.
// It allows to rate this movie
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import "Movie.h"

@interface MovieDetailsViewController : UIViewController <UIActionSheetDelegate, QBActionStatusDelegate>

@property (retain, nonatomic) IBOutlet UITextView *detailsText;
@property (retain, nonatomic) IBOutlet UIImageView *moviImageView;
@property (retain, nonatomic) IBOutlet UIButton *ratingButton;

@property (nonatomic, retain) Movie *movie;
@property (nonatomic, retain) RateView *ratingView;

- (IBAction)rate:(id)sender;

@end
