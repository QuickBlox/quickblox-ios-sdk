//
//  ChatModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ChatModuleViewController.h"

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
            numberOfRows = 7;
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
                    [cell.textLabel setText:@"Create room"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Join room"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Leave room"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Send message to room"];
                    break;
                    
                case 4:
                    [cell.textLabel setText:@"Request all rooms"];
                    break;
                    
                case 5:
                    [cell.textLabel setText:@"Add users to room"];
                    break;
                    
                case 6:
                    [cell.textLabel setText:@"Delete users from room"];
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
                    user.ID = 14605;
                    user.password = @"iostest2";
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
                    [message setRecipientID:14605];
                    [message setSenderID:14605];
                    
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
                // Create new room with name
                case 0:{
                    [[QBChat instance] createRoomWithName:@"exstasyroom10"];// room's name must be without spaces
                }
                break;
                    
                // Join room
                case 1:{
                    [[QBChat instance] joinRoom:testRoom];
                }
                break;
                
                // Leave room
                case 2:{
                    [[QBChat instance] leaveRoom:testRoom];
                }
                break;
                    
                // Send message
                case 3:{
                    [[QBChat instance] sendMessage:@"hello" toRoom:testRoom];
                }
                break;
                
                // Request all rooms
                case 4:{
                    [[QBChat instance] requestAllRooms];
                }
                break;
                
                // Add users to room
                case 6:{
                    NSNumber *user = [NSNumber numberWithInt:300];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] addUsers:users toRoom:testRoom];
                }
                break; 
                
                // Delete users from room
                case 7:{
                    NSNumber *user = [NSNumber numberWithInt:300];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] deleteUsers:users fromRoom:testRoom];
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

-(void) chatDidLogin{
    NSLog(@"Did login");
}

- (void)chatDidNotLogin{
    NSLog(@"Did not login");
}

-(void)chatDidNotSendMessage:(QBChatMessage *)message{
    NSLog(@"Did not send message");
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    NSLog(@"Did receive message: %@, from %d", message.text, message.senderID);
}

- (void)chatRoomDidCreate:(QBChatRoom*)room{
    NSLog(@"Room did create: %@", room.name);
    testRoom = [room retain];
}

- (void)chatRoomDidEnter:(NSString *)roomName{
     NSLog(@"chatRoomDidEnter: %@", roomName);
}

- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"chatRoomDidLeave: %@", roomName);
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName{
    NSLog(@"Did receive message: %@, from room %@", message, roomName);
}

- (void)chatDidReceiveListOfRooms:(NSArray *)_rooms{
    NSLog(@"Did receive list of rooms:");
    for (QBChatRoom* room in _rooms) {
        NSLog(@"%@",[room name]);
    }
}

- (void)chatRoomDidChangeMembers:(NSArray *)occupants room:(NSString *)roomName{
    NSLog(@"Room (%@) did change occupants: %@", roomName, occupants);
}

- (void)dealloc {
    [testRoom release];
    [super dealloc];
}
    
@end
