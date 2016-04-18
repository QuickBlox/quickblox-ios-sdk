//
//  ListOfUsersViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 26.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "ListOfUsersViewController.h"
#import "Settings.h"

@interface ListOfUsersViewController()

@property (copy, nonatomic) NSIndexPath *listIndexPath;

@end

@implementation ListOfUsersViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.listIndexPath = [NSIndexPath indexPathForRow:Settings.instance.listType inSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    void (^checkmakr)(BOOL) = ^(BOOL isCheckmark){
        
        if (isCheckmark) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    };
    
    if (indexPath.section == 0) {
        
        checkmakr([indexPath compare:self.listIndexPath] == NSOrderedSame);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        self.listIndexPath = indexPath;
        Settings.instance.listType = (ListOfUsers)indexPath.row;
    }
    
    [tableView reloadData];
}

@end
