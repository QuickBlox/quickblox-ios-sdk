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

@interface LatestCheckinsViewController ()

@end

@implementation LatestCheckinsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Latest checkins", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"speech_bubble.png"];
        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[DataManager shared].checkinArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QBLGeoData *geodata = [[DataManager shared].checkinArray objectAtIndex:indexPath.row];
        
    static NSString *CellIdentifier = @"Checkins";
    
	UILabel			*name;			// name 
    UILabel			*checkins;		// checkins
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // create photo
        UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 4, 42, 38)];
        [photo setImage:[UIImage imageNamed:@"pin.png"]];
        photo.tag = 1101;
        [cell.contentView addSubview:photo];
        
        // create name 
        name = [[UILabel alloc] initWithFrame:CGRectMake(85, 2, 155, 20)];
        name.tag = 1102;
        [name setFont:[UIFont boldSystemFontOfSize:15]];
        [name setTextColor:[UIColor colorWithRed:0.172 green:0.278 blue:0.521 alpha:1]];
        [name setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:name];
        
        // create cheсkins
        checkins = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, 155, 20)];
        checkins.tag = 1103;
        [checkins setFont:[UIFont systemFontOfSize:14]];
        [checkins setTextColor:[UIColor grayColor]];
        [checkins setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:checkins];
        
    }else{
        name = (UILabel *)[cell.contentView viewWithTag:1102];
        checkins = (UILabel *)[cell.contentView viewWithTag:1103];
    }
    if (geodata.user.login!=nil) {
        name.text=geodata.user.login;
    }else{
        name.text=geodata.user.fullName;
    }
    checkins.text=geodata.status;
    cell.contentView.tag = indexPath.row;
        
    return cell;
}


@end
