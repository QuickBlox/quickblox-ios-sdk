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

@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.movie.fields[@"name"];
    self.descriptionLabel.text = self.movie.fields[@"description"];
    [self.descriptionLabel sizeToFit];
    
    self.ratingView.maximumValue = 10;
    self.ratingView.minimumValue = 0;
    self.ratingView.allowsHalfStars = YES;
    self.ratingView.value = [self.movie.fields[@"rating"] floatValue];
    self.ratingView.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
