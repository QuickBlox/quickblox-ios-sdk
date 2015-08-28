//
//  ViewController.m
//  sample-messages
//
//  Created by Quickblox Team on 6/11/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "ViewController.h"
#import <Quickblox/Quickblox.h>
#import <SVProgressHUD.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) IBOutlet UITextField *pushMessageTextField;
@property (nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *pushMessages;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     self.pushMessages = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushDidReceive:)
                                                 name:@"kPushDidReceive"
                                               object:nil];
    
    [self registerForRemoteNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushDidReceive:(NSNotification *)notification
{
    NSString *message = [notification userInfo][@"message"];
    
    [self.pushMessages addObject:message];
    
    [self.tableView reloadData];
}

- (void)registerForRemoteNotifications
{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}

- (void)sendPushWithMessage:(NSString *)message
{
    NSString *currentUserId = [NSString stringWithFormat:@"%lu", (unsigned long)[QBSession currentSession].currentUser.ID];
    
    [SVProgressHUD showWithStatus:@"Sending a push"];
    
    [QBRequest sendPushWithText:message toUsers:currentUserId successBlock:^(QBResponse *response, NSArray *events) {
        
        [SVProgressHUD  dismiss];
        
        [ViewController showNotificationAlertViewWithTitle:@"Success" message:@"Your message successfully sended"];
        
    } errorBlock:^(QBError *error) {
        
        [SVProgressHUD  dismiss];
        
        [ViewController showAlertViewWithErrorMessage:[error description]];
    }];
    
}

- (void)checkCurrentUserWithCompletion:(void(^)(NSError *authError))completion
{
    if ([[QBSession currentSession] currentUser] != nil) {
        
        if (completion) completion(nil);
        
    } else {
        
        [SVProgressHUD showWithStatus:@"Initialising"];
        
        [QBRequest logInWithUserLogin:@"qbpushios" password:@"qbpushios" successBlock:^(QBResponse *response, QBUUser *user) {
            
            [SVProgressHUD dismiss];
            
            if (completion) completion(nil);
            
        } errorBlock:^(QBResponse *response) {
            
            [SVProgressHUD dismiss];
            
            if (completion) completion(response.error.error);
        }];
    }
}

- (IBAction)sendPush:(id)sender
{
    NSString *message = self.pushMessageTextField.text;
    
    // empty text
    if([message length] == 0) {
        
        [ViewController showNotificationAlertViewWithTitle:@"Validation" message:@"Please enter some text"];
        
    } else {
        
        [self checkCurrentUserWithCompletion:^(NSError *authError) {
           
            if (authError) {
                
                [ViewController showAlertViewWithErrorMessage:[authError localizedDescription]];
                
            } else {
                
                [self sendPushWithMessage:message];
            }
            
        }];
        
        [self.pushMessageTextField resignFirstResponder];
        self.pushMessageTextField.text = nil;
    }
}

#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pushMessages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushMessageCellIdentifier"];
    
    cell.textLabel.text = self.pushMessages[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.pushMessageTextField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark Helpers

+ (void)showAlertViewWithErrorMessage:(NSString *)errorMessage
{
    NSLog(@"Errors = %@", errorMessage);
    
    [self showNotificationAlertViewWithTitle:@"Error" message:errorMessage];
}

+ (void)showNotificationAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
