//
//  EditViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "EditViewController.h"
#import "MainViewController.h"

@interface EditViewController ()

@property (nonatomic, strong) IBOutlet UITextField* loginFiled;
@property (nonatomic, strong) IBOutlet UITextField* fullNameField;
@property (nonatomic, strong) IBOutlet UITextField* phoneField;
@property (nonatomic, strong) IBOutlet UITextField* emailField;
@property (nonatomic, strong) IBOutlet UITextField* websiteField;
@property (nonatomic, strong) IBOutlet UITextField *tagsField;

@end

@implementation EditViewController
@synthesize user;
@synthesize loginFiled;
@synthesize fullNameField;
@synthesize phoneField;
@synthesize emailField;
@synthesize websiteField;
@synthesize tagsField;
@synthesize mainController;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    loginFiled.text = mainController.currentUser.login;
    fullNameField.text = mainController.currentUser.fullName;
    phoneField.text = mainController.currentUser.phone;
    emailField.text = mainController.currentUser.email;
    websiteField.text = mainController.currentUser.website;
    
    for (NSString *tag in mainController.currentUser.tags) {
        if ([tagsField.text length] == 0) {
            tagsField.text = tag;
        } else {
            tagsField.text = [NSString stringWithFormat:@"%@, %@", tagsField.text, tag];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [loginFiled resignFirstResponder];
    [fullNameField resignFirstResponder];
    [phoneField resignFirstResponder];
    [emailField resignFirstResponder];
    [websiteField resignFirstResponder];
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

// Update user
- (void)update:(id)sender
{
    user = mainController.currentUser;
    
    if ([loginFiled.text length] != 0) user.login = loginFiled.text;

    if ([fullNameField.text length] != 0) user.fullName = fullNameField.text;

    if ([phoneField.text length] != 0) user.phone = phoneField.text;
    
    if ([emailField.text length] != 0) user.email = emailField.text;
    
    if ([websiteField.text length] != 0) user.website = websiteField.text;
    
    if ([tagsField.text length] != 0)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[tagsField.text stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
        user.tags = array;
    }
    
    // update user
    [QBRequest updateUser:user successBlock:^(QBResponse *response, QBUUser *aUser) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"User was edit successfully"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        mainController.currentUser = aUser;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } errorBlock:^(QBResponse *response) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (IBAction)back:(id)sender
{
    loginFiled.text = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
