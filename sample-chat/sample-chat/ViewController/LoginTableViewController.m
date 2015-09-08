//
//  LoginTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "LoginTableViewController.h"
#import "ServicesManager.h"
#import "UsersDataSource.h"

@interface LoginTableViewController ()

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;

@end

@implementation LoginTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self addBackgroundView];

	[self retrieveUsers];
}

- (void)addBackgroundView
{
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:imageView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:backgroundView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0f
                                                                constant:-25.0f]];
    
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:backgroundView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0f constant:0.0f]];
    self.tableView.backgroundView = backgroundView;
}

- (void)retrieveUsers
{
	__weak __typeof(self)weakSelf = self;
    
    // Retrieving users from cache.
	[ServicesManager.instance.usersService cachedUsersWithCompletion:^(NSArray *users) {
		if (users != nil && users.count != 0) {
			[weakSelf loadDataSourceWithUsers:users];
        } else {
            [weakSelf downloadLatestUsers];
        }
	}];
}

- (void)downloadLatestUsers
{
	if (self.isUsersAreDownloading) return;
    
	self.usersAreDownloading = YES;
	
	__weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"Loading users" maskType:SVProgressHUDMaskTypeClear];
	
    // Downloading latest users.
	[ServicesManager.instance.usersService downloadLatestUsersWithSuccessBlock:^(NSArray *latestUsers) {
        [SVProgressHUD showSuccessWithStatus:@"Completed"];
        [weakSelf loadDataSourceWithUsers:latestUsers];
        weakSelf.usersAreDownloading = NO;
	} errorBlock:^(QBResponse *response) {
		[SVProgressHUD showErrorWithStatus:@"Can not download users"];
		weakSelf.usersAreDownloading = NO;
	}];
}

- (void)loadDataSourceWithUsers:(NSArray *)users
{
	self.dataSource = [[UsersDataSource alloc] initWithUsers:users];
	self.tableView.dataSource = self.dataSource;
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeClear];
	
	QBUUser *selectedUser = self.dataSource.users[indexPath.row];
	selectedUser.password = @"x6Bt0VDy5"; // default password for test users
	
	__weak __typeof(self)weakSelf = self;
    // Logging in to Quickblox REST API and chat.
    [ServicesManager.instance logInWithUser:selectedUser completion:^(BOOL success, NSString *errorMessage) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"Logged in"];
            __typeof(self) strongSelf = weakSelf;
            [strongSelf performSegueWithIdentifier:kGoToDialogsSegueIdentifier sender:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Can not login"];
        }
    }];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)backToLoginViewController:(UIStoryboardSegue *)segue
{

}

@end
