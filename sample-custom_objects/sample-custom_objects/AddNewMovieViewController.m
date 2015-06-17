//
//  AddNewMovieViewController.m
//  sample-custom_objects
//
//  Created by Igor Khomenko on 6/10/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "AddNewMovieViewController.h"
#import "HCSStarRatingView.h"
#import "Storage.h"
#import <Quickblox/Quickblox.h>

@interface AddNewMovieViewController () <UIAlertViewDelegate>

@property (nonatomic) IBOutlet UITextField *nameView;
@property (nonatomic) IBOutlet UITextView *descriptionView;
@property (nonatomic) IBOutlet UITextField *yearView;
@property (nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end


@implementation AddNewMovieViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.descriptionView.layer.borderWidth = 1.0f;
    self.descriptionView.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
    self.descriptionView.layer.cornerRadius = 5;
    
    self.ratingView.maximumValue = 10;
    self.ratingView.minimumValue = 0;
    self.ratingView.allowsHalfStars = YES;
}

- (IBAction)create:(id)sender{
    // Create note
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = kMovieClassName;
    object.fields[@"name"] = self.nameView.text;
    object.fields[@"description"] = self.descriptionView.text;
    object.fields[@"year"] = self.yearView.text;
    object.fields[@"rating"] = @(self.ratingView.value);
    
    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        // save new movie to local storage
        [[Storage instance].moviesList addObject:object];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"You have created a new movie!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error in movie creation"
                                                        message:[response.error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }];
}

- (IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self cancel:nil];
}

@end
