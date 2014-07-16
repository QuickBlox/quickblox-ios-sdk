//
//  MainViewController.m
//  SimpleSample-messages_users-ios
//
//  Created by Igor Khomenko on 2/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "RichContentViewController.h"
#import "PushMessage.h"

@implementation MainViewController
@synthesize messageBody, receivedMessages;
@synthesize messages;

- (id)init{
    self = [super init];
    if(self){
        self.messages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    receivedMessages.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushDidReceive:) 
                                                 name:kPushDidReceive object:nil];
}

- (void)pushDidReceive:(NSNotification *)notification{
    // new push notification did receive - show it
    
    // push message
    NSString *message = [[notification userInfo] objectForKey:@"message"];
    
    // push rich content
    NSString *pushRichContent = [[notification userInfo] objectForKey:@"rich_content"];
    
    PushMessage *pushMessage = [PushMessage pushMessageWithMessage:message richContentFilesIDs:pushRichContent];
    [self.messages addObject:pushMessage];

    [receivedMessages reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return NO;
}

// Send push notification
- (IBAction)sendButtonDidPress:(id)sender{
    // empty text
    if([messageBody.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter some text" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    
    // send push
    }else{
        
        // Send push
        [QBMessages TSendPushWithText:messageBody.text
                             toUsers:@"1074264"
                            delegate:self];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [messageBody resignFirstResponder];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [messageBody resignFirstResponder];
}



#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result{
    // QuickBlox get Users result
    
    // Send Push result
    if([result isKindOfClass:[QBMSendPushTaskResult class]]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        // Success result
        if(result.success){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent successfully" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
        // Errors
        }else{
            NSLog(@"Errors=%@", result.errors);
        }
    }
}

- (void)buttonRichClicked:(UIButton *)sender{
    // Show rich content
    RichContentViewController *richContentViewController = [[RichContentViewController alloc] init];
    richContentViewController.message = [self.messages objectAtIndex:sender.tag];
    [self presentViewController:richContentViewController animated:YES completion:nil];
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PushCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PushMessage *pushMessage = [self.messages objectAtIndex:indexPath.row];
    if([[pushMessage richContentFilesIDs] count] > 0){
        
        // add rich button
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.tag = indexPath.row;
        myButton.frame = CGRectMake(260, 10, 40, 40);
        [myButton setBackgroundImage:[UIImage imageNamed:@"media_icon.jpeg"] forState:UIControlStateNormal];
        [myButton addTarget:self action:@selector(buttonRichClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:myButton];
    }
    
    cell.textLabel.text = [pushMessage message];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [messageBody resignFirstResponder];
    return YES;
}

@end
