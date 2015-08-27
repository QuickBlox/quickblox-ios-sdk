//
//  LatestCheckinsViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/18/12.
//
//

#import "SSLLatestCheckinsViewController.h"
#import "SSLAppDelegate.h"
#import "SSLDataManager.h"
#import "SSLAuthViewController.h"
#import "SSLCheckInTableViewCell.h"

static NSString* const CheckInCellIdentifier = @"CheckinCellIdentifier";

@interface SSLLatestCheckinsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SSLLatestCheckinsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = (UIEdgeInsets){20, 0, 0, 0};
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:SSLGeoDataManagerDidUpdateData object:nil];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[SSLDataManager instance].checkins count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBLGeoData *geodata = ([SSLDataManager instance].checkins)[indexPath.row];
    
    SSLCheckInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CheckInCellIdentifier];
    
    [cell configureWithGeoData:geodata];
   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

@end
