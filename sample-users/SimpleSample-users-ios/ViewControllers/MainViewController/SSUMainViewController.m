//
//  MainViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 24.02.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSUMainViewController.h"
#import "SSUUserTableViewCell.h"
#import "SSUUserDetailsViewController.h"

@interface SSUMainViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) NSMutableArray* searchUsers;

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation SSUMainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self retrieveUsers];
}

// Retrieve QuickBlox Users
- (void)retrieveUsers
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    @weakify(self);
    [QBRequest usersForPage:[QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:100] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *arrayOfUsers) {
        @strongify(self);
        self.users = arrayOfUsers;
        self.searchUsers = [arrayOfUsers mutableCopy];
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Errors = %@", response.error);
        [MTBlockAlertView showWithTitle:nil message:[response.error description]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UserDetailSegueIdentifier"]) {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        SSUUserDetailsViewController* detailsController = (SSUUserDetailsViewController *)segue.destinationViewController;
        detailsController.choosedUser = (self.searchUsers)[[indexPath row]];
    }
}

#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchUsers count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* SimpleTableIdentifier = @"SSUUserTableViewCellIdentifier";
    
    SSUUserTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    
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
#pragma mark UISearchDisplayControllerDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
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
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSString* scope = [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    [self filterContentForSearchText:searchString
                               scope:scope];
    
    return YES;
}

@end
