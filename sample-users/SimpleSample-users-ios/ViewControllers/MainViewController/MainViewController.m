//
//  MainViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController
@synthesize toolBar;
@synthesize searchBar;

@synthesize loginController;
@synthesize registrationController;
@synthesize currentUser = _currentUser;
@synthesize searchUsers;
@synthesize users, myTableView, _cell, editController, detailsController;

- (void)dealloc
{
    [users release];
    [searchUsers release];
    [_currentUser release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStyleBordered target:self action:@selector(signIn:)];
    signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUp:)];
    logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    editButton  = [[UIBarButtonItem alloc] initWithTitle:@"Self edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
    
    [self notLoggedIn];
    
    // retrieve users
    [self retrieveUsers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// User Sign In
- (IBAction)signIn:(id)sender
{
    // show User Sign In controller
    loginController.mainController = self;
    [self presentModalViewController:loginController animated:YES];
}

// User Sign Up
- (IBAction) signUp:(id)sender
{
    // show User Sign Up controller
    [self presentModalViewController:(UIViewController *)registrationController animated:YES];
}

// Logout User
- (IBAction)logout:(id)sender
{
    self.currentUser = nil;
    
    // logout user
    [QBUsers logOutWithDelegate:nil];
    
    [self notLoggedIn];
}

- (IBAction)edit:(id)sender
{
    editController.mainController = self;
    [self presentModalViewController:editController animated:YES];
}

- (void)notLoggedIn
{
    NSArray *items = [NSArray arrayWithObjects:signInButton, signUpButton, nil];
    [self.toolBar setItems:items animated:NO];
}

- (void)loggedIn
{
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 170;
    NSArray *items = [NSArray arrayWithObjects: editButton, fixedSpace, logoutButton, nil];
    [fixedSpace release];
    
    [self.toolBar setItems:items animated:NO];
}

// Retrieve QuickBlox Users
- (void) retrieveUsers{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // retrieve 100 users
    PagedRequest* request = [[PagedRequest alloc] init];
    request.perPage = 100;
	[QBUsers usersWithPagedRequest:request delegate:self];
	[request release];
}

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result
{
    // Retrieve Users result
    if([result isKindOfClass:[QBUUserPagedResult class]])
    {
        // Success result
        if (result.success)
        {
            // update table
            QBUUserPagedResult *usersSearchRes = (QBUUserPagedResult *)result;
            self.users = usersSearchRes.users;
            self.searchUsers = [[users mutableCopy] autorelease];
            [myTableView reloadData];
        
        // Errors
        }else{
            NSLog(@"Errors=%@", result.errors); 
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    // show user details
    detailsController.choosedUser = [self.searchUsers objectAtIndex:[indexPath row]];
    [self presentModalViewController:detailsController animated:YES];
    
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
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = _cell;
    }
    QBUUser* obtainedUser = [self.searchUsers objectAtIndex:[indexPath row]];
    if(obtainedUser.login != nil){
        cell.userLogin.text = obtainedUser.login;
    }
    else{
         cell.userLogin.text = obtainedUser.email;
    }
    
    for(NSString *tag in obtainedUser.tags){
        if([cell.userTag.text length] == 0){
             cell.userTag.text = tag;
        }else{
            cell.userTag.text = [NSString stringWithFormat:@"%@, %@", cell.userTag.text, tag];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


#pragma mark -
#pragma mark UISearchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)SearchBar{
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self.searchUsers removeAllObjects];
    
    if([searchText length] == 0){
        
        [self.searchUsers addObjectsFromArray:self.users];
        
    }else{
        for(QBUUser *user in self.users){
            
            NSRange loginRange = NSMakeRange(NSNotFound, 0);
            if(user.login != nil){
                loginRange = [user.login rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            NSRange fullNameRange = NSMakeRange(NSNotFound, 0);
            if(user.fullName != nil){
                fullNameRange= [user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            NSRange tagsRange = NSMakeRange(NSNotFound, 0);
            if(user.tags != nil && [user.tags count] > 0){
                tagsRange = [[user.tags description] rangeOfString:searchText options:NSCaseInsensitiveSearch];;
            }
            if(loginRange.location != NSNotFound || fullNameRange.location != NSNotFound || tagsRange.location != NSNotFound){
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
