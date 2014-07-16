//
//  RegistrationViewController.m
//  SimpleSample-location_users-ios
//
//  Created by Igor Khomenko on 04.10.11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

#import "RegistrationViewController.h"

@implementation RegistrationViewController
@synthesize userName;
@synthesize password;
@synthesize activityIndicator;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// User Sign Up
- (IBAction)next:(id)sender  {
    // Create QuickBlox User entity
    QBUUser *user = [QBUUser user];       
	user.password = password.text;
    user.login = userName.text;
    
    // create User
	[QBUsers signUp:user delegate:self];
    
    [activityIndicator startAnimating];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result{
    
    // QuickBlox User creation result
    if([result isKindOfClass:[QBUUserResult class]]){
        
        // Success result
		if(result.success){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration was successful. Please now sign in." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
		
        // Errors
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors" 
                                                            message:[NSString stringWithFormat:@"%@",result.errors] 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Okay" 
                                                  otherButtonTitles:nil, nil];
            [alert show];
		}
	}	
    
    [activityIndicator stopAnimating];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)_textField{ 
    [_textField resignFirstResponder];
    [self next:nil];
    return YES;
}


#pragma mark
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [password resignFirstResponder];
    [userName resignFirstResponder];
}

@end