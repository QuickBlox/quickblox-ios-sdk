//
//  UsersViewController.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UsersDataSource;
@class UsersViewController;

@protocol UsersViewControllerDelegate <NSObject>

- (void)usersViewController:(UsersViewController *)usersViewController didCreateChatDialog:(QBChatDialog *)chatDialog;

@end

@interface UsersViewController : UITableViewController

@property (weak, nonatomic) UsersDataSource *dataSource;
@property (weak, nonatomic) id<UsersViewControllerDelegate> delegate;

@end
