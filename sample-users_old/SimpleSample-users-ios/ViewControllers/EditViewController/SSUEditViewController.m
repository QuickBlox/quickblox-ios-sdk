//
//  EditViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSUEditViewController.h"
#import "SSUUserCache.h"

@interface SSUEditViewController ()

@property (nonatomic, strong) IBOutlet UITextField* loginTextField;
@property (nonatomic, strong) IBOutlet UITextField* fullNameTextField;
@property (nonatomic, strong) IBOutlet UITextField* phoneTextField;
@property (nonatomic, strong) IBOutlet UITextField* emailTextField;
@property (nonatomic, strong) IBOutlet UITextField* websiteTextField;
@property (nonatomic, strong) IBOutlet UITextField *tagsTextField;

@end

@implementation SSUEditViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    QBUUser* currentUser = [SSUUserCache instance].currentUser;
    self.loginTextField.text = currentUser.login;
    self.fullNameTextField.text = currentUser.fullName;
    self.phoneTextField.text = currentUser.phone;
    self.emailTextField.text = currentUser.email;
    self.websiteTextField.text = currentUser.website;
    
    for (NSString *tag in currentUser.tags) {
        if ([self.tagsTextField.text length] == 0) {
            self.tagsTextField.text = tag;
        } else {
            self.tagsTextField.text = [NSString stringWithFormat:@"%@, %@", self.tagsTextField.text, tag];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.loginTextField resignFirstResponder];
    [self.fullNameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
}

- (IBAction)updateButtonTouched:(id)sender
{
    QBUUser* currentUser = [[SSUUserCache instance].currentUser copy];
    if ([self.loginTextField.text length] != 0) currentUser.login = self.loginTextField.text;

    if ([self.fullNameTextField.text length] != 0) currentUser.fullName = self.fullNameTextField.text;

    if ([self.phoneTextField.text length] != 0) currentUser.phone = self.phoneTextField.text;
    
    if ([self.emailTextField.text length] != 0) currentUser.email = self.emailTextField.text;
    
    if ([self.websiteTextField.text length] != 0) currentUser.website = self.websiteTextField.text;
    
    if ([self.tagsTextField.text length] != 0)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[self.tagsTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
        currentUser.tags = array;
    }
    
    [QBRequest updateUser:currentUser successBlock:^(QBResponse *response, QBUUser *aUser) {
        [[SSUUserCache instance] saveUser:aUser];
        [MTBlockAlertView showWithTitle:@"User was edit successfully" message:nil];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } errorBlock:^(QBResponse *response) {
        
        [MTBlockAlertView showWithTitle:@"Error" message:[response.error description]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
