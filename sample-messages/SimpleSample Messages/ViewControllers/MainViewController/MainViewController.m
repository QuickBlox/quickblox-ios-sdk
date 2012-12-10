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
@synthesize users = _users;
@synthesize messageBody, receivedMassages, toUserName, usersPickerView;
@synthesize messages;

- (id)init{
    self = [super init];
    if(self){
        self.messages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidUnload{
    
    self.messageBody = nil;
    self.receivedMassages = nil;
    self.toUserName = nil;
    self.usersPickerView = nil;
    self.receivedMassages = nil;
    
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushDidReceive object:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    receivedMassages.layer.cornerRadius = 5;
    
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

    [receivedMassages reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return NO;
}

// Send push notification
- (IBAction)sendButtonDidPress:(id)sender{

    // not selected receiver(user)
   if([toUserName.text length] == 0 || [_users count] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please select user." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    // empty text
    }else if([messageBody.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter some text" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
    
    // send push
    }else{
        
        // Create message
        NSString *mesage = [NSString stringWithFormat:@"%@: %@", 
                            ((QBUUser *)[_users objectAtIndex:[usersPickerView selectedRowInComponent:0]]).login,  
                            messageBody.text];
        //
        NSMutableDictionary *payload = [NSMutableDictionary dictionary];
        NSMutableDictionary *aps = [NSMutableDictionary dictionary];
        [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
        [aps setObject:mesage forKey:QBMPushMessageAlertKey];
        [payload setObject:aps forKey:QBMPushMessageApsKey];
        //
        QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
        
        // receiver (user id)
        NSUInteger userID = ((QBUUser *)[_users objectAtIndex:[usersPickerView selectedRowInComponent:0]]).ID;
        
        // Send push
        [QBMessages TSendPush:message 
                             toUsers:[NSString stringWithFormat:@"%d", userID] 
              isDevelopmentEnvironment:YES 
                            delegate:self];
        
        [message release];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [messageBody resignFirstResponder];
    }
}

// Select receiver
- (IBAction)selectUserButtonDidPress:(id)sender{
    if(_users != nil){
         [self showPickerWithUsers];
        
    // retrieve all users
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // Retrieve QuickBlox users for current application
        PagedRequest *pagetRequest = [[[PagedRequest alloc] init] autorelease];
        pagetRequest.perPage = 30;
        [QBUsers usersWithPagedRequest:pagetRequest delegate:self];
    }
}

- (void) showPickerWithUsers{
    [usersPickerView reloadAllComponents];
    [usersPickerView setHidden:NO];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [messageBody resignFirstResponder];
}

- (void) dealloc{
    [messages release];
    [_users release];
    [super dealloc];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result{
    // QuickBlox get Users result
    
    if([result isKindOfClass:[QBUUserPagedResult  class]]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        // Success result
		if(result.success){
            
            // save users & show picker
            QBUUserPagedResult *res = (QBUUserPagedResult  *)result;
            self.users = res.users;
            [self showPickerWithUsers];
        
        // Errors
		}else {
            NSLog(@"Errors=%@", result.errors);
		}
        
    
    // Send Push result
    }else if([result isKindOfClass:[QBMSendPushTaskResult class]]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        // Success result
        if(result.success){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent successfully" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            [alert release];
            
        // Errors
        }else{
            NSLog(@"Errors=%@", result.errors);
        }
    }
}

- (IBAction)buttonRichClicked:(UIButton*)sender{
    // Show rich content
    RichContentViewController *richContentViewController = [[RichContentViewController alloc] init];
    richContentViewController.message = [self.messages objectAtIndex:sender.tag];
    [self presentModalViewController:richContentViewController animated:YES];
    [richContentViewController release];
}


#pragma mark -
#pragma mark UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_users count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return ((QBUUser *)[_users objectAtIndex:row]).login;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [toUserName setText: ((QBUUser *)[_users objectAtIndex:row]).login];
     [usersPickerView setHidden:YES];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
