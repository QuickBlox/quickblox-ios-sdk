//
//  UserDetailsViewController.h
//  sample-users
//
//  Created by Quickblox Team on 6/11/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@interface UserDetailsViewController : UITableViewController

@property (nonatomic, weak) QBUUser *user;

- (void)setupUIForShowUser;

@end
