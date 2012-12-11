//
//  UserTableViewCell.h
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/19/12.
//  Copyright (c) 2012 Ruslan. All rights reserved.
//
//
// This class presents user table view cell
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView  *icon;
@property (nonatomic, retain) UILabel      *text;
@property (nonatomic, retain) UIImageView  *status;

@end
