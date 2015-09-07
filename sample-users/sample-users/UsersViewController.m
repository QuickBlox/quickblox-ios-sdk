//
//  ViewController.m
//  sample-users
//
//  Created by Quickblox Team on 6/11/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "UsersViewController.h"
#import "UserDetailsViewController.h"
#import "Storage.h"
#import "UsersPaginator.h"

#import "UserTableViewCell.h"
#import "MenuTableViewCell.h"

#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

NS_ENUM(NSInteger, UsersViewControllerMenuMap) {
    UsersViewControllerMenuSignIn = 0,
    UsersViewControllerMenuSignUp,
    UsersViewControllerMenuEditUser,
    UsersViewControllerMenuSignOut
};

@interface UsersViewController () <UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate>

@property (nonatomic, strong) UsersPaginator *paginator;
@property (nonatomic, weak) UILabel *footerLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL isActionsOpened;

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateMenuSection:NO];
    [self updateTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self)weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [weakSelf setupTableViewFooter];
        
        [SVProgressHUD showWithStatus:@"Get users"];
        
        // Load files
        //
        [weakSelf.paginator fetchFirstPage];
    });
}

- (BOOL)isSignedIn {
    return [[QBSession currentSession] currentUser] != nil;
}

- (IBAction)actionsButtonClicked:(id)sender {
    
    self.isActionsOpened = !self.isActionsOpened;
    [self updateMenuSection:YES];
    [self updateTitle];
}

- (void)updateMenuSection:(BOOL)animated
{
    UITableViewRowAnimation animation = self.isActionsOpened ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    
    animation = animated ? animation : UITableViewRowAnimationNone;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
}

- (void)updateTitle
{
    self.title = [self isSignedIn] ? [[QBSession currentSession] currentUser].login : @"Not Signed In";
}

- (void)signOutAction {
    
    [SVProgressHUD showWithStatus:@"Logout user"];
    
    __weak typeof(self)weakSelf = self;
    
    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        [SVProgressHUD  dismiss];
        [weakSelf updateMenuSection:YES];
        [weakSelf updateTitle];
        
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];
        NSLog(@"Response error %@:", response.error);
    }];
}


#pragma mark
#pragma mark Paginator

- (void)fetchNextPage
{
    [self.paginator fetchNextPage];
    [self.activityIndicator startAnimating];
}

- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.tableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if ([self.paginator.results count] != 0) {
        self.footerLabel.text = [NSString stringWithFormat:@"%lu results out of %ld",
                                 (unsigned long)[self.paginator.results count], (long)self.paginator.total];
    } else {
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}


#pragma mark
#pragma mark Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    if ([segue.identifier isEqualToString:@"editUserSegue"]) {
        
        QBUUser *user = [[QBSession currentSession] currentUser];
        
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        destinationViewController.user = user;
        
    } else if ([segue.identifier isEqualToString:@"showUserSegue"]){
        
        NSUInteger row = sender.tag;
        QBUUser *user = [Storage instance].users[row];
        
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.user = user;
        [destinationViewController setupUIForShowUser];
        
    }
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height){
        // ask next page only if we haven't reached last page
        if(![self.paginator reachedLastPage]){
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}


#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    if (section == 0) {
        numberOfRowsInSection = self.isActionsOpened ? 4 : 0;
    } else {
        numberOfRowsInSection = [[Storage instance].users count];
    }
    
    return numberOfRowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        MenuTableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:@"MenuCellIdentifier"];
        
        switch (indexPath.row) {
            case UsersViewControllerMenuSignIn:
            {
                menuCell.menuTitleLabel.text = @"Sign In";
                menuCell.itemInactive = [self isSignedIn];
            }
                break;
                
            case UsersViewControllerMenuSignUp:
            {
                menuCell.menuTitleLabel.text = @"Sign Up";
                menuCell.itemInactive = [self isSignedIn];
            }
                break;
                
            case UsersViewControllerMenuEditUser:
            {
                menuCell.menuTitleLabel.text = @"Edit User";
                menuCell.itemInactive = ![self isSignedIn];
            }
                break;
                
            case UsersViewControllerMenuSignOut:
            {
                menuCell.menuTitleLabel.text = @"Logout";
                menuCell.itemInactive = ![self isSignedIn];
            }
                break;
                
            default:
                break;
        }
        
        cell = menuCell;
        
    } else {
        
        UserTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"UserCellIdentifier"];
        userCell.tag = indexPath.row;
        
        QBUUser *user = [Storage instance].users[indexPath.row];
        userCell.nameLabel.text = user.fullName != nil ? user.fullName : user.login;
        userCell.emailLabel.text = user.email;
        
        cell = userCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRowAtIndexPath = 0;
    
    if (indexPath.section == 0) {
        heightForRowAtIndexPath = 44;
    } else {
        heightForRowAtIndexPath = 64;
    }
    
    return heightForRowAtIndexPath;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = nil;
    
    if (section == 0) {
        
    } else {
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header.view"];
        
        if (!headerView) {
            headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header.view"];

            UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            sectionLabel.text = @"Select User";
            sectionLabel.font = [UIFont systemFontOfSize:14.0f];
            sectionLabel.textColor = [UIColor darkGrayColor];
            [sectionLabel sizeToFit];

            CGRect sectionLabelFrame = sectionLabel.frame;
            sectionLabelFrame.origin = CGPointMake(17, 10);
            sectionLabel.frame = sectionLabelFrame;
        
            [headerView addSubview:sectionLabel];
        }
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heightForHeader = 0;
    
    if (section == 0) {
        
    } else {
        heightForHeader = 38.0f;
    }
    
    return heightForHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case UsersViewControllerMenuSignIn:
            {
                if (![self isSignedIn]) {
                    [self performSegueWithIdentifier:@"signInSegue" sender:nil];
                }
            }
                break;
                
            case UsersViewControllerMenuSignUp:
            {
                if (![self isSignedIn]) {
                    [self performSegueWithIdentifier:@"signUpSegue" sender:nil];
                }
            }
                break;
                
            case UsersViewControllerMenuEditUser:
            {
                if ([self isSignedIn]) {
                    [self performSegueWithIdentifier:@"editUserSegue" sender:nil];
                }
            }
                break;
                
            case UsersViewControllerMenuSignOut:
            {
                if ([self isSignedIn]) {
                    [self signOutAction];
                }
            }
                break;
                
            default:
                break;
        }
        
    }
}


#pragma mark
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    // save files
    //
    [[Storage instance].users addObjectsFromArray:results];
    
    // update tableview footer
    [self updateTableViewFooter];
    [self.activityIndicator stopAnimating];
    
    // reload table
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

@end
