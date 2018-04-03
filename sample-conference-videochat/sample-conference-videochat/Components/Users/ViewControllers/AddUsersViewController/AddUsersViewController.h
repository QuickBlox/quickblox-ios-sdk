//
//  AddUsersViewController.h
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UsersDataSource;

@interface AddUsersViewController : UITableViewController

@property (weak, nonatomic) UsersDataSource *usersDataSource;
@property (weak, nonatomic) QBChatDialog *chatDialog;

@end
