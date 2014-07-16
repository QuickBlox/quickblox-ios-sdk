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

@property (nonatomic, strong) UIImageView *movieImageView;
@property (nonatomic, strong) UILabel *movieName;
@property (nonatomic, strong) RateView *ratingView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end
