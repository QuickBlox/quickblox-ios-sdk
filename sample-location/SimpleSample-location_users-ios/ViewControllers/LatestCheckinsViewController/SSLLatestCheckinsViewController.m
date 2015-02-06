//
//  LatestCheckinsViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/18/12.
//
//

#import "SSLLatestCheckinsViewController.h"
#import "SSLAppDelegate.h"
#import "SSLSplashViewController.h"
#import "SSLDataManager.h"
#import "SSLLoginViewController.h"
#import "SSLCheckInTableViewCell.h"

static NSString* const CheckInCellIdentifier = @"CheckinCellIdentifier";

@interface SSLLatestCheckinsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SSLLatestCheckinsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Latest checkins", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"speech_bubble.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"SSLCheckInTableViewCell" bundle:nil]
         forCellReuseIdentifier:CheckInCellIdentifier];
    self.tableView.contentInset = (UIEdgeInsets){20, 0, 0, 0};
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SSLDataManager instance].checkins.count;
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
