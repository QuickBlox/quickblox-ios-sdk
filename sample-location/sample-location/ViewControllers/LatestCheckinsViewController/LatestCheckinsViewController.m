//
//  LatestCheckinsViewController.m
//  sample-location
//
//  Created by Quickblox Team on 9/18/12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "LatestCheckinsViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "CheckInTableViewCell.h"

static NSString* const CheckInCellIdentifier = @"CheckinCellIdentifier";

@interface LatestCheckinsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation LatestCheckinsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = (UIEdgeInsets){20, 0, 0, 0};
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:GeoDataManagerDidUpdateData object:nil];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DataManager instance].checkins count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBLGeoData *geodata = ([DataManager instance].checkins)[indexPath.row];
    
    CheckInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CheckInCellIdentifier];
    
    [cell configureWithGeoData:geodata];
   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

@end
