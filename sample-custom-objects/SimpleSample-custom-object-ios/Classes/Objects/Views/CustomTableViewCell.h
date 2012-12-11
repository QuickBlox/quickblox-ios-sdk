//
//  CustomTableViewCell.h
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents table cell, that used for show note information 
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *noteLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UILabel *dataLabel;

@end
