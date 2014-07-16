//
//  MainViewController.h
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to work with QuickBlox Users module.
// It shows how to Sign In, Sign Out, Sign Up,
// how to use QuickBlox through social networks (Facebook, Twitter),
// retrieve all users, search users, edit user.
//

#import <UIKit/UIKit.h>
#import "UserDetailsViewController.h"
#import "LoginViewController.h"
#import "EditViewController.h"
#import "CustomTableViewCellCell.h"
#import "RegistrationViewController.h"

@class UserDetailsViewController;
@class EditViewController;
@class LoginViewController;
@class RegistrationViewController;

@interface MainViewController : UIViewController <QBActionStatusDelegate, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>{

    UIBarButtonItem *signInButton;
    UIBarButtonItem *signUpButton;
    UIBarButtonItem *logoutButton;
    UIBarButtonItem *editButton;
}

@property (nonatomic, strong) IBOutlet LoginViewController *loginController;
@property (nonatomic, strong) IBOutlet RegistrationViewController *registrationController;
@property (nonatomic, strong) IBOutlet EditViewController *editController;
@property (nonatomic, strong) IBOutlet UserDetailsViewController *detailsController;
@property (nonatomic, strong) IBOutlet CustomTableViewCellCell* _cell;

@property (nonatomic, strong) QBUUser *currentUser;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) NSMutableArray* searchUsers;

@property (nonatomic, strong) IBOutlet UITableView* myTableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

- (void) retrieveUsers;

- (IBAction) signIn:(id)sender;
- (IBAction) signUp:(id)sender;
- (IBAction) edit:(id)sender;
- (IBAction) logout:(id)sender;

- (void) loggedIn;
- (void) notLoggedIn;

@end
