//
//  CustomTableViewCell.h
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents custom table cell
//

#import <UIKit/UIKit.h>

@class  RateView;

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView *movieImageView;
@property (nonatomic, retain) UILabel *movieName;
@property (nonatomic, retain) RateView *ratingView;
@property (nonatomic, retain) UIImageView *backgroundImageView;

@end
