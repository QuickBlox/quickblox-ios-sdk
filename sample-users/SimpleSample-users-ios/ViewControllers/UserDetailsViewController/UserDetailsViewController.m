//
//  UserDetailsViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "UserDetailsViewController.h"

@implementation UserDetailsViewController

@synthesize lastRequestAtLabel;
@synthesize loginLabel;
@synthesize fullNameLabel;
@synthesize phoneLabel;
@synthesize emailLabel;
@synthesize websiteLabel;
@synthesize tagLabel;
@synthesize choosedUser;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show User's details
    loginLabel.text = choosedUser.login;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    lastRequestAtLabel.text = [dateFormatter stringFromDate:choosedUser.lastRequestAt ?
                               choosedUser.lastRequestAt : choosedUser.createdAt];
    
    fullNameLabel.text = choosedUser.fullName;
    phoneLabel.text = choosedUser.phone;
    emailLabel.text = choosedUser.email;
    websiteLabel.text = choosedUser.website;
    
    for(NSString *tag in choosedUser.tags){
        if([tagLabel.text length] == 0){
            tagLabel.text = tag;
        }else{
            tagLabel.text = [NSString stringWithFormat:@"%@, %@", tagLabel.text, tag];
        }
    }
    
    if ([choosedUser.fullName length] == 0)
    {
        fullNameLabel.text = @"empty"; 
        fullNameLabel.alpha = 0.3;
    }
    if ([choosedUser.phone length] == 0) 
    {
        phoneLabel.text = @"empty"; 
        phoneLabel.alpha = 0.3;
    }
    if ([choosedUser.email length] == 0) 
    {
        emailLabel.text = @"empty"; 
        emailLabel.alpha = 0.3;
    }
    if ([choosedUser.website length] == 0) 
    {
        websiteLabel.text = @"empty"; 
        websiteLabel.alpha = 0.3;
    }
    if ([choosedUser.tags count] == 0)
    {
        tagLabel.text = @"empty";
        tagLabel.alpha = 0.3;
    }
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
