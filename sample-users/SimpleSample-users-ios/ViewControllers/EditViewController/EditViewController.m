//
//  EditViewController.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 13.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

@end

@implementation EditViewController
@synthesize user, loginFiled, fullNameField, phoneField, emailField, websiteField, tagsField, mainController;

-(void)dealloc
{
    [mainController release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    loginFiled.text    = mainController.currentUser.login;
    fullNameField.text = mainController.currentUser.fullName;
    phoneField.text    = mainController.currentUser.phone;
    emailField.text    = mainController.currentUser.email;
    websiteField.text  = mainController.currentUser.website;
    
    for(NSString *tag in mainController.currentUser.tags){
        if([tagsField.text length] == 0){
            tagsField.text = tag;
        }else{
            tagsField.text = [NSString stringWithFormat:@"%@, %@", tagsField.text, tag];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [loginFiled resignFirstResponder];
    [fullNameField resignFirstResponder];
    [phoneField resignFirstResponder];
    [emailField resignFirstResponder];
    [websiteField resignFirstResponder];
}

- (IBAction) hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

// Update user
- (void)update:(id)sender
{
    user = mainController.currentUser;
    
    if ( [loginFiled.text length] != 0)
    {
        user.login = loginFiled.text;
    }
    if ([fullNameField.text length] != 0)
    {
        user.fullName = fullNameField.text;
    }
    if ([phoneField.text length] != 0)
    {
        user.phone = phoneField.text;
    }
    if ([emailField.text length] != 0) {
        user.email = emailField.text;
    }
    if ([websiteField.text length] != 0)
    {
        user.website = websiteField.text;
    }
    if([tagsField.text length] != 0)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[tagsField.text stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
        user.tags = array;
        [array release];
    }
    
    // update user
    [QBUsers updateUser:user delegate:self];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (IBAction)back:(id)sender
{
    loginFiled.text = nil;
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Edit user result
    if([result isKindOfClass:[QBUUserResult class]])
    {
        // Success result
        if (result.success)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:@"User was edit successfully" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            mainController.currentUser = user;
        
        // Errors
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:[result.errors description]
                                                    delegate:nil 
                                                    cancelButtonTitle:@"Okay" 
                                                    otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
}

@end
