//
//  UserDetailsViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSUUserDetailsViewController.h"

@interface SSUUserDetailsViewController ()

@property (nonatomic, strong) IBOutlet UILabel *lastRequestAtLabel;
@property (nonatomic, strong) IBOutlet UILabel *loginLabel;
@property (nonatomic, strong) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *phoneLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UILabel *websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel *tagLabel;

@end

@implementation SSUUserDetailsViewController

- (void)replaceText:(NSString *)text inLabelIfEmpty:(UILabel *)label
{
    if (text.length == 0) {
        label.text = @"empty";
        label.alpha = 0.3;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setTitle:self.choosedUser.fullName];
    
    self.loginLabel.text = self.choosedUser.login;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSDate* lastRequestDate = self.choosedUser.lastRequestAt ? self.choosedUser.lastRequestAt : self.choosedUser.createdAt;
    self.lastRequestAtLabel.text = [dateFormatter stringFromDate:lastRequestDate];
    
    self.fullNameLabel.text = self.choosedUser.fullName;
    self.phoneLabel.text = self.choosedUser.phone;
    self.emailLabel.text = self.choosedUser.email;
    self.websiteLabel.text = self.choosedUser.website;
    
    for (NSString *tag in self.choosedUser.tags) {
        if ([self.tagLabel.text length] == 0) {
            self.tagLabel.text = tag;
        } else {
            self.tagLabel.text = [NSString stringWithFormat:@"%@, %@", self.tagLabel.text, tag];
        }
    }
    
    [self replaceText:self.choosedUser.fullName inLabelIfEmpty:self.fullNameLabel];
    [self replaceText:self.choosedUser.phone inLabelIfEmpty:self.phoneLabel];
    [self replaceText:self.choosedUser.email inLabelIfEmpty:self.emailLabel];
    [self replaceText:self.choosedUser.website inLabelIfEmpty:self.websiteLabel];
    
    if([self.choosedUser.tags count] == 0)
    {
        self.tagLabel.text = @"empty";
        self.tagLabel.alpha = 0.3;
    }
}

@end
