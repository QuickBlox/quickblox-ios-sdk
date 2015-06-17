//
//  UserDetailsViewController.h
//  sample-users
//
//  Created by Igor Khomenko on 6/11/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@interface UserDetailsViewController : UIViewController

@property (nonatomic) QBUUser *user;

@end
