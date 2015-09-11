//
//  MovieDetailsViewController.m
//  sample-custom_objects
//
//  Created by Quickblox Team on 6/10/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "HCSStarRatingView.h"

@interface MovieDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.movieTitleLabel.text = self.movie.fields[@"name"];
    self.descriptionLabel.text = self.movie.fields[@"description"];
    
    self.ratingView.maximumValue = 5;
    self.ratingView.minimumValue = 0;
    self.ratingView.allowsHalfStars = NO;
    
    NSInteger value = [self.movie.fields[@"rating"] integerValue];
    value = MIN(MAX(self.ratingView.minimumValue, value), self.ratingView.maximumValue);
    
    self.ratingView.value = value;
    self.ratingView.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
