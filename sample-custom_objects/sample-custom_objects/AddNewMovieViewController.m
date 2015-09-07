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
#import "SAMTextView.h"

@interface AddNewMovieViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet SAMTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end


@implementation AddNewMovieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ratingView.maximumValue = 5;
    self.ratingView.minimumValue = 0;
    self.ratingView.allowsHalfStars = NO;
    self.descriptionTextView.placeholder = @"Description";
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

#pragma mark
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat heightForHeader = [super tableView:tableView heightForHeaderInSection:section];
    
    if (section == 1) {
        heightForHeader = 38.0f;
    }
    
    return heightForHeader;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.0f, tableView.bounds.size.width, 0.0f, 0.0f);
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [super tableView:tableView viewForHeaderInSection:section];
    
    if (section == 1) {
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header.view"];
        
        if (!headerView) {
            headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header.view"];
            
            UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            sectionLabel.text = @"Rating";
            sectionLabel.font = [UIFont systemFontOfSize:14.0f];
            sectionLabel.textColor = [UIColor darkGrayColor];
            [sectionLabel sizeToFit];
            
            CGRect sectionLabelFrame = sectionLabel.frame;
            sectionLabelFrame.origin = CGPointMake(17, 10);
            sectionLabel.frame = sectionLabelFrame;
            
            [headerView addSubview:sectionLabel];
        }
    }
    
    return headerView;
}

@end
