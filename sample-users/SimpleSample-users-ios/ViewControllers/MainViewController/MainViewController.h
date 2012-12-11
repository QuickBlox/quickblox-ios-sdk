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

@property (nonatomic, retain) IBOutlet LoginViewController *loginController;
@property (nonatomic, retain) IBOutlet RegistrationViewController *registrationController;
@property (nonatomic, retain) IBOutlet EditViewController *editController;
@property (nonatomic, retain) IBOutlet UserDetailsViewController *detailsController;
@property (nonatomic, retain) IBOutlet CustomTableViewCellCell* _cell;

@property (nonatomic, retain) QBUUser *currentUser;
@property (nonatomic, retain) NSArray* users;
@property (nonatomic, retain) NSMutableArray* searchUsers;

@property (nonatomic, retain) IBOutlet UITableView* myTableView;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

- (void) retrieveUsers;

- (IBAction) signIn:(id)sender;
- (IBAction) signUp:(id)sender;
- (IBAction) edit:(id)sender;
- (IBAction) logout:(id)sender;

- (void) loggedIn;
- (void) notLoggedIn;

@end
