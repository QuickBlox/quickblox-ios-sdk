//
//  UserDetailsViewController.m
//  sample-users
//
//  Created by Igor Khomenko on 6/11/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "UserDetailsViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface UserDetailsViewController ()

@property (nonatomic) IBOutlet UITextField *loginTextField;
@property (nonatomic) IBOutlet UITextField *fullnameTextField;
@property (nonatomic) IBOutlet UITextField *emailTextField;
@property (nonatomic) IBOutlet UITextField *phonenumberTextField;
@property (nonatomic) IBOutlet UITextField *tagsTextField;
@property (nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation UserDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.user.fullName != nil ? self.user.fullName : self.user.login;
    
    if(!self.user.ID == [QBSession currentSession].currentUser.ID){
        self.saveButton.hidden = YES;
        
        self.loginTextField.enabled = NO;
        self.fullnameTextField.enabled = NO;
        self.emailTextField.enabled = NO;
        self.phonenumberTextField.enabled = NO;
        self.tagsTextField.enabled = NO;
    }
    
    self.loginTextField.text = self.user.login;
    self.fullnameTextField.text = self.user.fullName;
    self.emailTextField.text = self.user.email;
    self.phonenumberTextField.text = self.user.phone;
    self.tagsTextField.text = [self.user.tags componentsJoinedByString:@","];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender{
    [SVProgressHUD showWithStatus:@"Updating user"];
    
    QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
    if(self.loginTextField.text.length > 0){
        updateParameters.login = self.loginTextField.text;
    }
    if(self.fullnameTextField.text.length > 0){
        updateParameters.fullName = self.fullnameTextField.text;
    }
    if(self.emailTextField.text.length > 0){
        updateParameters.email = self.emailTextField.text;
    }
    if(self.phonenumberTextField.text.length > 0){
        updateParameters.phone = self.phonenumberTextField.text;
    }
    if(self.tagsTextField.text.length > 0){
        updateParameters.tags = [[self.tagsTextField.text componentsSeparatedByString:@","] mutableCopy];
    }
    
    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
        [SVProgressHUD dismiss];
        
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];
        
        NSLog(@"Errors=%@", [response.error description]);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[response.error  description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

@end
