//
//  StunViewController.m
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 07.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "StunSettingsViewController.h"
#import "SVProgressHUD.h"
#import "Settings.h"

@interface StunSettingsViewController ()

@property (strong, nonatomic) NSDictionary *collection;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSMutableArray *selectedServers;

@end

@implementation StunSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadStunServers];
}

- (void)loadStunServers {
    
    self.selectedServers = [NSMutableArray array];
    
    [self.selectedServers addObjectsFromArray:Settings.instance.stunServers];  
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"StunList" ofType:@"plist"];
    self.collection = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    self.titles = self.collection.allKeys;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *title = self.titles[indexPath.row];
    NSString *url = self.collection[title];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = url;

    if ([self.selectedServers containsObject:url]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSString *key = self.titles[indexPath.row];
    NSString *url = self.collection[key];
    
    if ([self.selectedServers containsObject:url]) {
        [self.selectedServers removeObject:url];
    }
    else {
        
        [self.selectedServers addObject:url];
    }
    
    [self.tableView reloadData];
    Settings.instance.stunServers = self.selectedServers.copy;
    
}

@end
