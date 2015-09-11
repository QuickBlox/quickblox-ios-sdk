//
//  MenuTableViewCell.h
//  sample-users
//
//  Created by Injoit on 9/7/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (nonatomic, assign) BOOL itemInactive;

@end
