//
//  StunViewController.m
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 07.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "StunSettingsViewController.h"
#import "Settings.h"
#import "SampleCore.h"

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
    
    [self.selectedServers addObjectsFromArray:[SampleCore settings].stunServers];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"StunList" ofType:@"plist"];
	
    self.collection = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    self.titles = self.collection.allKeys;
	
	__weak __typeof(self)weakSelf = self;
	
	[self addSection:SettingsSectionStun items:^NSArray *{
        
		NSMutableArray *items = [NSMutableArray array];
		[weakSelf.collection enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
			BaseItemModel *baseItem = [[BaseItemModel alloc] initWithTitle:key];
			[items addObject:baseItem];
		}];
        
		return [items copy];
	}];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	BaseSettingsCell *cell = (BaseSettingsCell *) [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
    NSString *title = self.titles[indexPath.row];
    NSString *url = self.collection[title];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = url;

    BOOL isCheckmark = [self.selectedServers containsObject:url];
    cell.accessoryType = isCheckmark ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
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
    [SampleCore settings].stunServers = self.selectedServers.copy;
    
}

@end
