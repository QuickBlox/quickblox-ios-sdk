//
//  AddNewMovieViewController.m
//  sample-custom_objects
//
//  Created by Quickblox Team on 6/10/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "AddNewMovieViewController.h"
#import "HCSStarRatingView.h"
#import "Storage.h"
#import <Quickblox/Quickblox.h>

@interface AddNewMovieViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end


@implementation AddNewMovieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.layer.borderWidth = 1.0f;
    self.descriptionTextView.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
    self.descriptionTextView.layer.cornerRadius = 5;
    
    self.ratingView.maximumValue = 10;
    self.ratingView.minimumValue = 0;
    self.ratingView.allowsHalfStars = YES;
}

- (void)addNewMovie
{
    // Create note
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = kMovieClassName;
    object.fields[@"name"] = self.titleTextField.text;
    object.fields[@"description"] = self.descriptionTextView.text;
    object.fields[@"year"] = self.yearTextField.text;
    object.fields[@"rating"] = @(self.ratingView.value);
    
    __weak typeof(self)weakSelf = self;
    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        // save new movie to local storage
        [[Storage instance].moviesList addObject:object];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"You have created a new movie!"
                                                       delegate:weakSelf
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error in movie creation"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (BOOL)isTitleTextValid
{
    return (self.titleTextField.text != nil && self.titleTextField.text.length > 0);
}

- (BOOL)isDescriptionTextValid
{
    return (self.descriptionTextView.text != nil && self.descriptionTextView.text.length > 0);
}

- (BOOL)isYearTextValid
{
    return (self.yearTextField.text != nil && self.yearTextField.text.length > 0);
}

- (IBAction)create:(id)sender
{
    BOOL isValidInput = YES;
    if (![self isTitleTextValid]) {
        self.titleLabel.textColor = [UIColor redColor];
        isValidInput = NO;
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    if (![self isDescriptionTextValid]) {
        self.descriptionLabel.textColor = [UIColor redColor];
        isValidInput = NO;
    } else {
        self.descriptionLabel.textColor = [UIColor blackColor];
    }
    
    if (![self isYearTextValid]) {
        self.yearLabel.textColor = [UIColor redColor];
        isValidInput = NO;
    } else {
        self.yearLabel.textColor = [UIColor blackColor];
    }
    
    if (isValidInput) {
        [self addNewMovie];
    }
    
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self cancel:nil];
}

@end
