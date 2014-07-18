//
//  MainViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "UserDetailsViewController.h"
#import "LoginViewController.h"
#import "EditViewController.h"
#import "CustomTableViewCellCell.h"
#import "RegistrationViewController.h"

@interface MainViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet LoginViewController *loginController;
@property (nonatomic, strong) IBOutlet RegistrationViewController *registrationController;
@property (nonatomic, strong) IBOutlet EditViewController *editController;
@property (nonatomic, strong) IBOutlet UserDetailsViewController *detailsController;
@property (nonatomic, strong) IBOutlet CustomTableViewCellCell* _cell;

@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) NSMutableArray* searchUsers;

@property (nonatomic, strong) IBOutlet UITableView* myTableView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation MainViewController {
    UIBarButtonItem *signInButton;
    UIBarButtonItem *signUpButton;
    UIBarButtonItem *logoutButton;
    UIBarButtonItem *editButton;
}

@synthesize toolBar;
@synthesize searchBar;

@synthesize loginController;
@synthesize registrationController;
@synthesize currentUser = _currentUser;
@synthesize searchUsers;
@synthesize users, myTableView, _cell, editController, detailsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil]
           forCellReuseIdentifier:@"SimpleTableIdentifier"];
    
    signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStyleBordered target:self action:@selector(signIn:)];
    signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUp:)];
    logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    editButton  = [[UIBarButtonItem alloc] initWithTitle:@"Self edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
    
    [self notLoggedIn];
    
    // retrieve users
    [self retrieveUsers];
}

// User Sign In
- (void)signIn:(id)sender
{
    // show User Sign In controller
    loginController.mainController = self;
    [self presentViewController:loginController animated:YES completion:nil];
}

// User Sign Up
- (void)signUp:(id)sender
{
    // show User Sign Up controller
    [self presentViewController:registrationController animated:YES completion:nil];
}

// Logout User
- (void)logout:(id)sender
{
    self.currentUser = nil;
    
    // logout user
    [QBRequest logOutWithSuccessBlock:nil errorBlock:nil];
    
    [self notLoggedIn];
}

- (void)edit:(id)sender
{
    editController.mainController = self;
    [self presentViewController:editController animated:YES completion:nil];
}

- (void)notLoggedIn
{
    NSArray *items = @[signInButton, signUpButton];
    [self.toolBar setItems:items animated:NO];
}

- (void)loggedIn
{
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 170;
    NSArray *items = @[editButton, fixedSpace, logoutButton];
    
    [self.toolBar setItems:items animated:NO];
}

// Retrieve QuickBlox Users
- (void)retrieveUsers
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // retrieve 100 users
    [QBRequest usersForPage:[QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:100] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *arrayOfUsers) {
        self.users = arrayOfUsers;
        self.searchUsers = [arrayOfUsers mutableCopy];
        [myTableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Errors = %@", response.error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    // show user details
    detailsController.choosedUser = (self.searchUsers)[[indexPath row]];
    [self presentViewController:detailsController animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchUsers count];
}

// Making table view using custom cells 
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    CustomTableViewCellCell* cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    
    QBUUser* obtainedUser = (self.searchUsers)[[indexPath row]];
    if (obtainedUser.login != nil) {
        cell.userLogin.text = obtainedUser.login;
    } else {
        cell.userLogin.text = obtainedUser.email;
    }
    
    for (NSString *tag in obtainedUser.tags) {
        if ([cell.userTag.text length] == 0) {
            cell.userTag.text = tag;
        } else {
            cell.userTag.text = [NSString stringWithFormat:@"%@, %@", cell.userTag.text, tag];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchUsers removeAllObjects];
    
    if([searchText length] == 0) {
        [self.searchUsers addObjectsFromArray:self.users];
    } else {
        for(QBUUser *user in self.users) {
            NSRange loginRange = NSMakeRange(NSNotFound, 0);
            if (user.login != nil) {
                loginRange = [user.login rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            NSRange fullNameRange = NSMakeRange(NSNotFound, 0);
            if (user.fullName != nil) {
                fullNameRange= [user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            NSRange tagsRange = NSMakeRange(NSNotFound, 0);
            if(user.tags != nil && [user.tags count] > 0) {
                tagsRange = [[user.tags description] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            if (loginRange.location != NSNotFound || fullNameRange.location != NSNotFound || tagsRange.location != NSNotFound) {
                [self.searchUsers addObject:user];
            }
        }
    }
    
    [self.myTableView reloadData];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
    [_textField resignFirstResponder];
    return YES;
}

- (void)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

@end
