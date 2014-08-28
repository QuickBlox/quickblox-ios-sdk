//
//  MainViewController.m
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "CustomTableViewCell.h"
#import "RateView.h"
#import "MovieDetailsViewController.h"
#import "Movie.h"
#import "DataManager.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Movies";
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) showMovieDetails:(int)index{
    MovieDetailsViewController *detailsViewController = [[MovieDetailsViewController alloc] init];
    [detailsViewController setMovie:[[[DataManager shared] movies] objectAtIndex:index]];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showMovieDetails:indexPath.row];
}

- (void)tableView:(UITableView *)_tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self showMovieDetails:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[DataManager shared] movies] count];
}

// Making table view using custom cells
- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    CustomTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil){
        cell = [[CustomTableViewCell alloc] init];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    Movie *movie = [[[DataManager shared] movies] objectAtIndex:indexPath.row];
    
    // Show movie's label, image & rate
    [cell.movieName setText:(NSString *)[movie movieName]];
    [cell.movieImageView setImage:[UIImage imageNamed:[movie movieImage]]];
    if([movie rating]){
        cell.ratingView.rate = [movie rating];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


@end
