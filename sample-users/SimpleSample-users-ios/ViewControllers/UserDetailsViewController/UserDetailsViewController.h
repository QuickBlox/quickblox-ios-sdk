//
//  UserDetailsViewController.h
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows QB user's details
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface UserDetailsViewController : UIViewController{
}
@property (nonatomic, retain) IBOutlet UILabel *lastRequestAtLabel;
@property (nonatomic, retain) IBOutlet UILabel *loginLabel;
@property (nonatomic, retain) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *phoneLabel;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet UILabel *websiteLabel;
@property (nonatomic, retain) IBOutlet UILabel *tagLabel;

@property (nonatomic, retain) QBUUser *choosedUser;

- (IBAction)back:(id)sender;

@end
