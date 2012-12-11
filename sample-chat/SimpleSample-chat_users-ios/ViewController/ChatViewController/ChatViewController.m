//
//  ChatViewController.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ChatViewController.h"
#include "ChatMessageTableViewCell.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize opponent;
@synthesize currentRoom;
@synthesize messages;

@synthesize toolBar;
@synthesize sendMessageField;
@synthesize sendMessageButton;
@synthesize tableView;

#pragma mark -
#pragma mark View controller's lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    // Chat in room
    if(!self.opponent){
        
        messages = [[NSMutableArray alloc] init];
        
    // Chat 1-1
    }else{
        
        // load history
        messages = [[[DataManager shared] chatHistoryWithOpponentID:self.opponent.ID] retain];
        
        NSLog(@"q");
        
        if(messages == nil){
            messages = [[NSMutableArray alloc] init];
        }
    }
    
    // set chat delegate
    [[QBChat instance] setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // leave room
    if(self.currentRoom){
        if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
            // back button was pressed.
            [[QBChat instance] leaveRoom:self.currentRoom];
            [[DataManager shared].rooms removeObject:self.currentRoom];
        }
    }
}

- (void)viewDidUnload{
    [self setToolBar:nil];
    [self setSendMessageField:nil];
    [self setSendMessageButton:nil];
    [self setTableView:nil];
    
    [messages release];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [currentRoom release];
    [messages release];
    [opponent release];
    [super dealloc];
}


#pragma mark -
#pragma mark Methods


- (IBAction)sendMessage:(id)sender {
    if(self.sendMessageField.text.length == 0){
        return;
    }
    
    // Send message to opponent
    if(self.opponent){
        // send message
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.recipientID = opponent.ID;
        message.senderID = [[DataManager shared] currentUser].ID;
        message.text = self.sendMessageField.text;
        [[QBChat instance] sendMessage:message];

        // save message to cache
        [self.messages addObject:message];
        [[DataManager shared] saveMessage:[NSKeyedArchiver archivedDataWithRootObject:messages]
                 toHistoryWithOpponentID:self.opponent.ID];
        [message release];
        
        
        // Check if user offline -> send push notifications to him
        // if user didn't do anything last 5 minutes - he is offline
        NSInteger currentDate = [[NSDate date] timeIntervalSince1970];
        if(currentDate - [self.opponent.lastRequestAt timeIntervalSince1970] > 300){
            
            // Create push message
			NSString *mesage = self.sendMessageField.text;
			//
			NSMutableDictionary *payload = [NSMutableDictionary dictionary];
			NSMutableDictionary *aps = [NSMutableDictionary dictionary];
			[aps setObject:@"default" forKey:QBMPushMessageSoundKey];
			[aps setObject:mesage forKey:QBMPushMessageAlertKey];
			[payload setObject:aps forKey:QBMPushMessageApsKey];
			//
			QBMPushMessage *message = [[QBMPushMessage alloc] initWithPayload:payload];
            
            BOOL isDevEnv = NO;
#ifdef DEBUG
            isDevEnv = YES;
#endif
            
			// Send push
			[QBMessages TSendPush:message
                          toUsers:[NSString stringWithFormat:@"%d", self.opponent.ID]
         isDevelopmentEnvironment:isDevEnv
                         delegate:nil];
            
            [message release];
        }
        
        
        // reload table
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    // Send message to room
    }else if(self.currentRoom){
    
        [[QBChat instance] sendMessage:self.sendMessageField.text toRoom:self.currentRoom];
        
        // reload table
        [self.tableView reloadData];
    }
    
    // hide keyboard & clean text field
    [self.sendMessageField resignFirstResponder];
    [self.sendMessageField setText:nil];
}

-(void)keyboardShow{
    CGRect rectFild = self.sendMessageField.frame;
    rectFild.origin.y -= 215;
    
    CGRect rectButton = self.sendMessageButton.frame;
    rectButton.origin.y -= 215;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self.sendMessageField setFrame:rectFild];
                         [self.sendMessageButton setFrame:rectButton];
                     }
     ];
}

-(void)keyboardHide{
    CGRect rectFild = self.sendMessageField.frame;
                         rectFild.origin.y += 215;
    CGRect rectButton = self.sendMessageButton.frame;
                         rectButton.origin.y += 215;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self.sendMessageField setFrame:rectFild];
                         [self.sendMessageButton setFrame:rectButton];
                     }
     ];
}


#pragma mark - 
#pragma mark TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardShow];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardHide];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField setText:nil];
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

static CGFloat padding = 20.0;
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"MessageCellIdentifier";

	
    // Create cell
	ChatMessageTableViewCell *cell = (ChatMessageTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:CellIdentifier] autorelease];
	}
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
    
    
    // Message
    QBChatMessage *messageBody = [messages objectAtIndex:[indexPath row]];
    
    // set message's text
	NSString *message = [messageBody text];
    cell.message.text = message;
    
    // message's datetime
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat: @"yyyy-mm-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *time = [formatter stringFromDate:messageBody.datetime];
        
	
	CGSize textSize = { 260.0, 10000.0 };
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize
						  lineBreakMode:UILineBreakModeWordWrap];
	size.width += (padding/2);
	
    
    // Left/Right bubble
    UIImage *bgImage = nil;
    if ([[[DataManager shared] currentUser] ID] == messageBody.senderID || self.currentRoom) {
        
        bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.message setFrame:CGRectMake(padding, padding*2, size.width+padding, size.height+padding)];
        
        [cell.backgroundImageView setFrame:CGRectMake( cell.message.frame.origin.x - padding/2,
                                              cell.message.frame.origin.y - padding/2,
                                              size.width+padding, 
                                              size.height+padding)];
        
        cell.date.textAlignment = UITextAlignmentLeft;
        cell.backgroundImageView.image = bgImage;
        
        if(self.currentRoom){
            cell.date.text = [NSString stringWithFormat:@"%@ %@", [self title], time];
        }else{
            cell.date.text = [NSString stringWithFormat:@"%@ %@", [[[DataManager shared] currentUser] login], time];
        }
        
    } else {
        
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.message setFrame:CGRectMake(320 - size.width - padding,
                                                     padding*2, 
                                                     size.width+padding, 
                                                     size.height+padding)];
        
        [cell.backgroundImageView setFrame:CGRectMake(cell.message.frame.origin.x - padding/2,
                                              cell.message.frame.origin.y - padding/2,
                                              size.width+padding, 
                                              size.height+padding)];
        
        cell.date.textAlignment = UITextAlignmentRight;
        cell.backgroundImageView.image = bgImage;
        cell.date.text = [NSString stringWithFormat:@"%@ %@", self.opponent.login, time];
    }
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *msg = ((QBChatMessage *)[messages objectAtIndex:indexPath.row]).text;
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
                  constrainedToSize:textSize 
                      lineBreakMode:UILineBreakModeWordWrap];
	
	size.height += padding;
	return size.height+padding+5;
}


#pragma mark -
#pragma mark QBChatDelegate

// Did receive 1-1 message
- (void)chatDidReceiveMessage:(QBChatMessage *)message{

	[self.messages addObject:message];
    
    // save message to cache if this 1-1 chat
    if (self.opponent) {
        [[DataManager shared] saveMessage:[NSKeyedArchiver archivedDataWithRootObject:messages]
                  toHistoryWithOpponentID:self.opponent.ID];
    }
    
    // reload table
	[self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// Did receive message in room
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(QBChatRoom *)room{
    // save message
	[self.messages addObject:message];

    // reload table
	[self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// Fired when you did leave room
- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"Chat Controller chatRoomDidLeave");
}


// Called in case changing occupant
- (void)chatRoomDidChangeMembers:(NSArray *)members room:(NSString *)roomName{
    NSLog(@"chatRoomDidChangeMembers=%@ in room: %@", members, roomName);
}

@end
