//
//  MainViewController.m
//  SimpleSample-messages_users-ios
//
//  Created by Igor Khomenko on 2/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "SSMMainViewController.h"
#import "SSMRichContentViewController.h"
#import "SSMPushMessage.h"

@interface SSMMainViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) IBOutlet UITextField *messageBodyTextField;
@property (nonatomic, strong) IBOutlet UITableView *receivedMessagesTableView;

@end

@implementation SSMMainViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.messages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.receivedMessagesTableView.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushDidReceive:) 
                                                 name:kPushDidReceive
                                               object:nil];
}

- (void)pushDidReceive:(NSNotification *)notification
{
    // new push notification did receive - show it
    
    // push message
    NSString *message = [notification userInfo][@"message"];
    
    // push rich content
    NSString *pushRichContent = [notification userInfo][@"rich_content"];
    
    SSMPushMessage *pushMessage = [SSMPushMessage pushMessageWithMessage:message richContentFilesIDs:pushRichContent];
    [self.messages addObject:pushMessage];

    [self.receivedMessagesTableView reloadData];
}

// Send push notification
- (IBAction)sendButtonDidPress:(id)sender
{
    // empty text
    if([self.messageBodyTextField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter some text"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [QBRequest sendPushWithText:self.messageBodyTextField.text toUsers:@"1074264" successBlock:^(QBResponse *response, QBMEvent *event) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent successfully" message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } errorBlock:^(NSError *error) {
            NSLog(@"Errors=%@", [error description]);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [self.messageBodyTextField resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.messageBodyTextField resignFirstResponder];
}

- (void)showRichContentControllerForMessage:(SSMPushMessage *)message
{
    SSMRichContentViewController *richContentViewController = [[SSMRichContentViewController alloc] init];
    richContentViewController.message = message;
    [self presentViewController:richContentViewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSMPushMessage *pushMessage = (self.messages)[indexPath.row];
    if (pushMessage.richContentFilesIDs.count > 0) {
        [self showRichContentControllerForMessage:pushMessage];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PushCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    SSMPushMessage *pushMessage = (self.messages)[indexPath.row];
    if ([[pushMessage richContentFilesIDs] count] > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [pushMessage message];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
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
    [self.messageBodyTextField resignFirstResponder];
    return YES;
}

@end
