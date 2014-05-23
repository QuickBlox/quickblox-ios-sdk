//
//  MovieDetailsViewController.m
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "Movie.h"
#import "DataManager.h"


@interface MovieDetailsViewController ()

@end

@implementation MovieDetailsViewController
@synthesize ratingButton;
@synthesize movie;
@synthesize detailsText;
@synthesize moviImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = movie.movieName;

    [self.detailsText setText:[movie movieDetails]];
    [self.detailsText setEditable:NO];
    [self.moviImageView setImage:[UIImage imageNamed:[movie movieImage]]];
    
    
    self.ratingView = [[[RateView alloc] initWithFrameBig:CGRectMake(40, 328, 240, 40)] autorelease];
    self.ratingView.alignment = RateViewAlignmentLeft;
    self.ratingView.editable = NO;
    self.ratingView.rate = [movie rating];
    [self.view addSubview:self.ratingView];
    
    if(IS_HEIGHT_GTE_568){
        CGRect frame = self.ratingView.frame;
        frame.origin.y += 88;
        [self.ratingView setFrame:frame];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [detailsText release];
    [ratingButton release];
    [super dealloc];
}

- (IBAction)rate:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Rate movie" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1", @"2", @"3", @"4", @"5", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex > 0){
        QBRScore *score = [QBRScore score];
        score.gameModeID = [movie gameModeID];
        score.value = buttonIndex + 1;
        [QBRatings createScore:score delegate:nil];
    }
    
    [actionSheet release];
}

@end
