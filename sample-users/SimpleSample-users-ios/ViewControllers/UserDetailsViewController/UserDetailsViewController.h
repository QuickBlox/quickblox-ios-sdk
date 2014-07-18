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
@property (nonatomic, strong) IBOutlet UILabel *lastRequestAtLabel;
@property (nonatomic, strong) IBOutlet UILabel *loginLabel;
@property (nonatomic, strong) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *phoneLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UILabel *websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel *tagLabel;

@property (nonatomic, strong) QBUUser *choosedUser;

- (IBAction)back:(id)sender;

@end
