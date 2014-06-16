//
//  LatestCheckinsViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/18/12.
//
//

#import "LatestCheckinsViewController.h"
#import "AppDelegate.h"
#import "SplashViewController.h"
#import "DataManager.h"
#import "LoginViewController.h"
#import "CheckInTableViewCell.h"

static NSString* const CheckInCellIdentifier = @"CheckinCellIdentifier";

@interface LatestCheckinsViewController () <UITableViewDataSource>

@end

@implementation LatestCheckinsViewController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckInTableViewCell" bundle:nil]
         forCellReuseIdentifier:CheckInCellIdentifier];
    self.tableView.contentInset = (UIEdgeInsets){20, 0, 0, 0};
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataManager instance].checkinArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBLGeoData *geodata = ([DataManager instance].checkinArray)[indexPath.row];
    
    CheckInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CheckInCellIdentifier];
    
    [cell configureWithGeoData:geodata];
   
    return cell;
}

@end
