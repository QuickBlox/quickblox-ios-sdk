//
//  ChatModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ChatModuleViewController.h"

#define testRoomName @"footballFansFroup5"

@interface ChatModuleViewController ()

@end

@implementation ChatModuleViewController
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Chat", @"Chat");
        self.tabBarItem.image = [UIImage imageNamed:@"circle.png"];
        
        // set Chat delegate
        [[QBChat instance] setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 4;
            break;
        case 1:
            numberOfRows = 1;
            break;
        case 2:
            numberOfRows = 9;
            break;
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* headerTitle;
    switch (section) {
        case 0:
            headerTitle = @"Sign In/Sign Out";
            break;
        case 1:
            headerTitle = @"1 to 1 chat";
            break;
        case 2:
            headerTitle = @"Rooms";
            break;
        default:
            headerTitle = @"";
            break;
    }
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
            // section Sign In/Sign Out
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Login"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Is Logged In"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Logout"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Send presence"];
                    break;
                    
                default:
                    break;
            }
            break;
            
            // section 1 to 1 chat
        case 1:
            [cell.textLabel setText:@"Send message"];
            break;
            
            // section Rooms
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Create public room"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Create only members room"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Join room"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Leave room"];
                    break;
                    
                case 4:
                    [cell.textLabel setText:@"Send message to room"];
                    break;
                    
                case 5:
                    [cell.textLabel setText:@"Request all rooms"];
                    break;
                    
                case 6:
                    [cell.textLabel setText:@"Add users to room"];
                    break;
                    
                case 7:
                    [cell.textLabel setText:@"Delete users from room"];
                    break;
                    
                case 8:
                    [cell.textLabel setText:@"Request room users"];
                    break;
                    
                    
                default:
                    break;
            }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    switch (indexPath.section) {
        
        // Sign In/Sign Out
        case 0:
            switch (indexPath.row) {
                // Login
                case 0:{
                    QBUUser *user = [QBUUser user];
#if (TARGET_IPHONE_SIMULATOR)
                    user.ID = 298;
                    user.password = @"bobbobbob";
#else
                    user.ID = 300;
                    user.password = @"emma";
#endif
                    [[QBChat instance] loginWithUser:user];
                }
                    
                break;
                    
                // Is logged in
                case 1:{
                    [[QBChat instance] isLoggedIn];
                }
                    break;
                    
                //  Logout
                case 2:{
                    [[QBChat instance] logout];
                }
                    break;
                    
                // Send presence
                case 3:
                    [[QBChat instance] sendPresence];
                    break;
                    
                default:
                    break;
            }
            break;
            
        // 1 to 1 chat
        case 1:
            switch (indexPath.row) {
                // send message
                case 0:{

                    QBChatMessage* message = [[QBChatMessage alloc] init];
                    [message setText:@"Hello iOS developer!"];
                    [message setRecipientID:300];
                    [message setSenderID:300];
                    
                    [[QBChat instance] sendMessage:message];
                    
                    [message release];
                }
                default:
                    break;
            }
            break;
            
        // Rooms
        case 2:
            switch (indexPath.row) {
                // Create new public room with name
                case 0:{
                    [[QBChat instance] createRoomWithName:testRoomName];// room's name must be without spaces
                }
                break;
                    
                // Create new only members room with name
                case 1:{
                    [[QBChat instance] createPrivateRoomWithName:testRoomName];// room's name must be without spaces
                }
                    break;
                    
                // Join room
                case 2:{
                    [[QBChat instance] joinRoom:testRoom];
                }
                break;
                
                // Leave room
                case 3:{
                    [[QBChat instance] leaveRoom:testRoom];
                }
                break;
                    
                // Send message
                case 4:{
                    [[QBChat instance] sendMessage:@"hello" toRoom:testRoom];
                }
                break;
                
                // Request all rooms
                case 5:{
                    [[QBChat instance] requestAllRooms];
                }
                break;
                
                // Add users to room
                case 6:{
                    NSNumber *user = [NSNumber numberWithInt:298];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] addUsers:users toRoom:testRoom];
                }
                break; 
                
                // Delete users from room
                case 7:{
                    NSNumber *user = [NSNumber numberWithInt:298];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] deleteUsers:users fromRoom:testRoom];
                }
                break;
                    
                // Request room users
                case 8:{
                    [[QBChat instance] requestRoomUsers:testRoom];
                }
                break;
                
                default:
                    break;
            }
            
        default:
            break;
    }
}

    
#pragma mark -
#pragma mark QBChatDelegate

//********************** Auth
//

-(void) chatDidLogin{
    NSLog(@"Did login");

    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
}

- (void)chatDidNotLogin{
    NSLog(@"Did not login");
}

- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type{
     NSLog(@"chatDidReceivePresenceOfUser %i, type: %@ ", userID, type);
}

//********************** Messaging
//

-(void)chatDidNotSendMessage:(QBChatMessage *)message{
    NSLog(@"Did not send message");
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    NSLog(@"Did receive message: %@, from %d", message.text, message.senderID);
}

//********************** Rooms
//

- (void)chatDidReceiveListOfRooms:(NSArray *)_rooms{
    NSLog(@"Did receive list of rooms:");
    for (QBChatRoom* room in _rooms) {
        if([room.name isEqualToString:testRoomName]){
            testRoom = [room retain];
        }
        NSLog(@"%@",[room name]);
    }
}

- (void)chatRoomDidCreate:(QBChatRoom*)room{
    NSLog(@"Room did create: %@", room.name);
    testRoom = [room retain];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName{
    NSLog(@"Did receive message: %@, from room %@", message, roomName);
}

- (void)chatRoomDidEnter:(NSString *)roomName{
     NSLog(@"chatRoomDidEnter: %@", roomName);
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    NSLog(@"chatRoomDidNotEnter: %@  %@", roomName, error);
}

- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"chatRoomDidLeave: %@", roomName);
}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName{
    NSLog(@"chatRoomDidChangeOnlineUsers %@, %@",roomName, onlineUsers);
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName{
    NSLog(@"chatRoomDidReceiveListOfUsers %@, %@",roomName, users);
}

- (void)dealloc {
    [testRoom release];
    [super dealloc];
}
    
@end
