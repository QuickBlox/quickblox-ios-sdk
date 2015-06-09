//
//  DialogInfoTableViewController.m
//  sample-chat
//
//  Created by Andrey Moskvin on 6/9/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "DialogInfoTableViewController.h"
#import "UsersDataSource.h"
#import "StorageManager.h"

@interface DialogInfoTableViewController()

@property (nonatomic, strong) UsersDataSource* usersDatasource;

@end

@implementation DialogInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usersDatasource = [[UsersDataSource alloc] initWithUsers:[StorageManager instance].users];
    self.tableView.dataSource = self.usersDatasource;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"kShowDialogInfoViewController"]) {
        DialogInfoTableViewController* viewController = segue.destinationViewController;
        viewController.dialog = self.dialog;
    }
}

@end
