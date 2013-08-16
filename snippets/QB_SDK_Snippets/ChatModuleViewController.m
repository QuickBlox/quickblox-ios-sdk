//
//  ChatModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ChatModuleViewController.h"

#define testRoomName @"xmppchat"

#define ADMIN_ID 291


@interface ChatModuleViewController ()

@end

@implementation ChatModuleViewController
@synthesize tableView = _tableView;
@synthesize testRoom;

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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 3;
            break;
        case 1:
            numberOfRows = 3;
            break;
        case 2:
            numberOfRows = 1;
            break;
        case 3:
            numberOfRows = 4;
            break;
        case 4:
            numberOfRows = 13;
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
            headerTitle = @"Presence";
            break;
        case 2:
            headerTitle = @"1 to 1 chat";
            break;
        case 3:
            headerTitle = @"Contact List";
            break;
        case 4:
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
                    
                default:
                    break;
            }
            break;
            
          
        // Presence section
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Send presence"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Send presence with status"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Send direct presence with status"];
                    break;
                    
                default:
                    break;
            }
            break;

            
        // section 1 to 1 chat
        case 2:
            [cell.textLabel setText:@"Send message"];
            break;
            
        // section Contact list
        case 3:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Add user to contact list request"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Confirm add request"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Reject add request"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Remove user from contact list"];
                    break;
                    
                default:
                    break;
            }
            break;
            
        // section Rooms
        case 4:
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
                    [cell.textLabel setText:@"Send presence to room"];
                    break;
                    
                case 6:
                    [cell.textLabel setText:@"Request all rooms"];
                    break;
                    
                case 7:
                    [cell.textLabel setText:@"Add users to room"];
                    break;
                    
                case 8:
                    [cell.textLabel setText:@"Delete users from room"];
                    break;
                    
                case 9:
                    [cell.textLabel setText:@"Request room users"];
                    break;
                
                case 10:
                    [cell.textLabel setText:@"Request room online users"];
                    break;
                    
                case 11:
                    [cell.textLabel setText:@"Request room information"];
                    break;
                    
                case 12:
                    [cell.textLabel setText:@"Destroy room"];
                    break;
                    
                default:
                    break;
            }
            break;
        
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
#if TARGET_IPHONE_SIMULATOR
                    user.ID = 218650;
                    user.password = @"injoitUser1";
#else
                    user.ID = 218650;
                    user.password = @"injoitUser1";
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
                    
                default:
                    break;
            }
            break;

        // Presence
        case 1:
            switch (indexPath.row) {
                // send Presence
                case 0:{
                    [[QBChat instance] sendPresence];
                }
                    break;
                    
                // send Presence with status
                case 1:{
                    [[QBChat instance] sendPresenceWithStatus:@"morning mate"];
                }
                    break;
                    
                // send direct Presence with status
                case 2:{
#if TARGET_IPHONE_SIMULATOR
                    [[QBChat instance] sendDirectPresenceWithStatus:@"morning" toUser:218650];
#else
                    [[QBChat instance] sendDirectPresenceWithStatus:@"morning" toUser:218651];
#endif
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        // 1 to 1 chat
        case 2:
            switch (indexPath.row) {
                // send message
                case 0:{

                    QBChatMessage *message = [QBChatMessage message];
                    [message setText:@"Hello QuickBlox developer!"];
                    [message setCustomParameters:@{@"playSound": @YES}];
#if TARGET_IPHONE_SIMULATOR
                    [message setRecipientID:218650];
#else
                    [message setRecipientID:218651];
#endif
                    [[QBChat instance] sendMessage:message];
                }
                default:
                    break;
            }
            break;
            
        // Contact list
        case 3:
            switch (indexPath.row) {
                    
                // Add user to contact list request
                case 0:{
#if TARGET_IPHONE_SIMULATOR
                    [[QBChat instance] addUserToContactListRequest:218650];
#else
                    [[QBChat instance] addUserToContactListRequest:218651];
#endif
                }
                    break;
                  
                // Confirm add request
                case 1:{
#if TARGET_IPHONE_SIMULATOR
                    [[QBChat instance] confirmAddContactRequest:218650];
#else
                    [[QBChat instance] confirmAddContactRequest:218651];
#endif
                }
                    break;
                    
                // Reject add request
                case 2:{
#if TARGET_IPHONE_SIMULATOR
                    [[QBChat instance] rejectAddContactRequest:218650];
#else
                    [[QBChat instance] rejectAddContactRequest:218651];
#endif
                }
                    break;
                    
                // Remove user from contact list
                case 3:{
#if TARGET_IPHONE_SIMULATOR
                    [[QBChat instance] removeUserFromContactList:218650];
#else
                    [[QBChat instance] removeUserFromContactList:218651];
#endif
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        // Rooms
        case 4:
            switch (indexPath.row) {
                // Create new public room with name
                case 0:{
                    self.testRoom = nil;
                    
                    // room's name must be without spaces
                    [[QBChat instance] createOrJoinRoomWithName:testRoomName membersOnly:NO persistent:NO];
                    
                    
                }
                break;
                    
                // Create new only members room with name
                case 1:{
                    self.testRoom = nil;
                    
                    // room's name must be without spaces
                    [[QBChat instance] createOrJoinRoomWithName:testRoomName membersOnly:YES persistent:NO];
                }
                    break;
                    
                // Join room
                case 2:{
                    self.testRoom= [[QBChatRoom alloc] initWithRoomName:testRoomName];
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
                    [[QBChat instance] sendMessage:@"Hello QuickBlox team, this is iOS SDK mate!" toRoom:testRoom];
                }
                break;
                    
                // Send presence
                case 5:{
                    [[QBChat instance] sendPresenceWithParameters:@{@"job": @"manager", @"sex": @"man"} toRoom:testRoom];
                }
                    break;
                
                // Request all rooms
                case 6:{
                    [[QBChat instance] requestAllRooms];
                }
                break;
                
                // Add users to room
                case 7:{
                    NSNumber *user = [NSNumber numberWithInt:291];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] addUsers:users toRoom:testRoom];
                }
                break; 
                
                // Delete users from room
                case 8:{
                    NSNumber *user = [NSNumber numberWithInt:298];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] deleteUsers:users fromRoom:testRoom];
                }
                break;
                    
                // Request room users
                case 9:{
                    [[QBChat instance] requestRoomUsers:testRoom];
                }
                break;
                    
                // Request room online users
                case 10:{
                    QBChatRoom *_room = [[QBChatRoom alloc] initWithRoomName:testRoomName];
                    [_room requestOnlineUsers];
                    [_room release];
                }
                    break;
                    
                // Request room information
                case 11:{
                    [[QBChat instance] requestRoomInformation:testRoom];
                }
                    break;
                    
                // Destroy room
                case 12:{
                    [[QBChat instance] destroyRoom:testRoom];
                }
                    break;
                
                default:
                    break;
            }
            break;
            
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

    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(sendPresence) userInfo:nil repeats:YES];
}

- (void)sendPresence{
    [[QBChat instance] sendPresence];
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
    NSLog(@"Did receive message: %@", message);
}

//********************** Contact list
//

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID{
    NSLog(@"chatDidReceiveContactAddRequestFromUser %d", userID);
}

- (void)chatContactListDidChange:(QBContactList *)contactList{
    if([contactList.contacts count] > 0 || [contactList.pendingApproval count] > 0){
        NSLog(@"contactList %@", contactList);
    }
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status{
     NSLog(@"chatDidReceiveContactItemActivity, user: %d, isOnline: %d, status: %@", userID, isOnline, status);
}

//********************** Rooms
//

- (void)chatDidReceiveListOfRooms:(NSArray *)_rooms{
    NSLog(@"Did receive list of rooms: %@", _rooms);
    for (QBChatRoom* room in _rooms) {
        if([room.name isEqualToString:testRoomName]){
            self.testRoom = room;
        }
    }
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName{
    NSLog(@"Did receive message: %@, from room %@", message, roomName);
}

- (void)chatRoomDidCreate:(NSString *)roomName{
    NSLog(@"chatRoomDidCreate: %@", roomName);
}

- (void)chatRoomDidEnter:(QBChatRoom *)room{
    if(room != self.testRoom){
        self.testRoom = room;
    }
    
    // add admin to room
    [room addUsers:@[@ADMIN_ID]];

    NSLog(@"chatRoomDidEnter: %@", room);
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    NSLog(@"chatRoomDidNotEnter: %@  %@", roomName, error);
}

- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"chatRoomDidLeave: %@", roomName);
    self.testRoom = nil;
}

- (void)chatRoomDidDestroy:(NSString *)roomName{
    NSLog(@"chatRoomDidDestroy: %@", roomName);
}

- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName{
    NSLog(@"chatRoomDidReceiveInformation %@, %@",roomName, information);
}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName{
    NSLog(@"chatRoomDidChangeOnlineUsers %@, %@",roomName, onlineUsers);
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName{
    NSLog(@"chatRoomDidReceiveListOfUsers %@, %@",roomName, users);
}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName{
     NSLog(@"chatRoomDidReceiveListOfOnlineUsers %@, %@",roomName, users);
}

- (void)dealloc {
    [testRoom release];
    [super dealloc];
}
    
@end
