//
//  NewDialogTableViewController.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/29/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "NewDialogTableViewController.h"
#import "UsersDataSource.h"

@implementation NewDialogTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[(UsersDataSource *)self.tableView.dataSource setExcludeCurrentUser:YES];
}

@end
