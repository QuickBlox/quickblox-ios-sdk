//
//  ViewController.m
//  sample-messages
//
//  Created by Igor Khomenko on 6/11/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     self.pushMessages = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushDidReceive:)
                                                 name:@"kPushDidReceive"
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [SVProgressHUD showWithStatus:@"Initialising"];
        
        // Your app connects to QuickBlox server here.
        //
        QBSessionParameters *parameters = [QBSessionParameters new];
        parameters.userLogin = @"qbpushios";
        parameters.userPassword = @"qbpushios";
        
        [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
            [self registerForRemoteNotifications];

        }errorBlock:^(QBResponse *response) {
            NSLog(@"Response error %@:", response.error);
            [SVProgressHUD dismiss];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[response.error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushDidReceive:(NSNotification *)notification{
    NSString *message = [notification userInfo][@"message"];
    
    [self.pushMessages addObject:message];
    
    [self.tableView reloadData];
}

- (void)registerForRemoteNotifications{
    
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

- (IBAction)sendPush:(id)sender{
    // empty text
    if([self.pushMessageTextField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter some text"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [SVProgressHUD showWithStatus:@"Sending a push"];
        
        NSString *currentUserId = [NSString stringWithFormat:@"%lu",
                                   (unsigned long)[QBSession currentSession].currentUser.ID];
        [QBRequest sendPushWithText:self.pushMessageTextField.text toUsers:currentUserId successBlock:^(QBResponse *response, NSArray *events) {
            [SVProgressHUD  dismiss];
        } errorBlock:^(QBError *error) {
            NSLog(@"Errors=%@", [error.reasons description]);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [SVProgressHUD  dismiss];
        }];
        
        [self.pushMessageTextField resignFirstResponder];
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

@end
