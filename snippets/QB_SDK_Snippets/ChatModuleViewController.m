//
//  ChatModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ChatModuleViewController.h"

#define testRoomName @"test_name_room_public"

#define ADMIN_ID 103894

@interface ChatModuleViewController () <QBActionStatusDelegate>

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
        [QBChat instance].useMutualSubscriptionForContactList = NO;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
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
            numberOfRows = 13;
            break;
        case 4:
            numberOfRows = 4;
            break;
        case 5:
            numberOfRows = 6;
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
            headerTitle = @"Rooms";
            break;
        case 4:
            headerTitle = @"Contact List";
            break;
        case 5:
            headerTitle = @"History";
            break;
        default:
            headerTitle = @"";
            break;
            
    }
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
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
            
            
        // section Rooms
        case 3:
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
            
        // section Contact list
        case 4:
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
            
        case 5:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"Get Dialogs"];
                    break;
                    
                case 1:
                    [cell.textLabel setText:@"Get Messages"];
                    break;
                    
                case 2:
                    [cell.textLabel setText:@"Create Dialog"];
                    break;
                    
                case 3:
                    [cell.textLabel setText:@"Update Dialog"];
                    break;
                    
                case 4:
                    [cell.textLabel setText:@"Update Message"];
                    break;
                    
                case 5:
                    [cell.textLabel setText:@"Delete Message"];
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
                    user.ID = UserID1;
                    user.password = UserPasswordForChat1;

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
                    [[QBChat instance] sendDirectPresenceWithStatus:@"morning" toUser:33];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        // 1 to 1 chat
        case 2:
            switch (indexPath.row) {
                // send chat 1-1 message
                case 0:{

                    QBChatMessage *message = [QBChatMessage message];
                    [message setText:[NSString stringWithFormat:@"banana%d", rand()]];
                    [message setRecipientID:UserID2];
                    //
//                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                    params[@"date_sent"] = @((int)[[NSDate date] timeIntervalSince1970]);
//                    params[@"save_to_history"] = @YES;
//                    [message setCustomParameters:params];
//                    QBChatAttachment *attachment = QBChatAttachment.new;
//                    attachment.type = @"image";
//                    attachment.ID = @"47863";
//                    [message setAttachments:@[attachment]];
                    //
                    [[QBChat instance] sendMessage:message];
                    
                    
                }
                default:
                    break;
            }
            break;
            
            
        // Rooms
        case 3:
            switch (indexPath.row) {
                // Create new public room with name
                case 0:{
                    self.testRoom = nil;
                    
                    // room's name must be without spaces
                    [[QBChat instance] createOrJoinRoomWithName:testRoomName membersOnly:NO persistent:YES];
                    
                }
                break;
                    
                // Create new only members room with name
                case 1:{
                    self.testRoom = nil;
                    
                    // room's name must be without spaces
                    [[QBChat instance] createOrJoinRoomWithName:testRoomName membersOnly:YES persistent:YES];
                }
                    break;
                    
                // Join room
                case 2:{
                    self.testRoom = [[QBChatRoom alloc] initWithRoomJID:testRoomJID];
                    [self.testRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"50"}];
                }
                break;
                
                // Leave room
                case 3:{
                    [[QBChat instance] leaveRoom:testRoom];
                }
                break;
                    
                // Send message
                case 4:{
                    QBChatMessage *message = [QBChatMessage message];
                    [message setText:[NSString stringWithFormat:@"banana%d", rand()]];
                    //
//                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                    params[@"date_sent"] = @((int)[[NSDate date] timeIntervalSince1970]);
//                    params[@"save_to_history"] = @YES;
//                    [message setCustomParameters:params];
//                    QBChatAttachment *attachment = QBChatAttachment.new;
//                    attachment.type = @"image";
//                    attachment.ID = @"47863";
//                    [message setAttachments:@[attachment]];
                    //
                    [[QBChat instance] sendChatMessage:message toRoom:testRoom];
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
                    NSNumber *user = [NSNumber numberWithInt:298];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] addUsers:users toRoom:testRoom];
                }
                break; 
                
                // Delete users from room
                case 8:{
                    NSNumber *user = [NSNumber numberWithInt:1279283];
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
                    QBChatRoom *_room = [[QBChatRoom alloc] initWithRoomJID:testRoomJID];
                    [_room requestOnlineUsers];
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
            
        // Contact list
        case 4:
            switch (indexPath.row) {
                    
                // Add user to contact list request
                case 0:{
                    [[QBChat instance] addUserToContactListRequest:946391];
                }
                    break;
                    
                // Confirm add request
                case 1:{
                    [[QBChat instance] confirmAddContactRequest:946390];
                }
                    break;
                    
                // Reject add request
                case 2:{
                    [[QBChat instance] rejectAddContactRequest:946390];
                }
                    break;
                    
                // Remove user from contact list
                case 3:{
                    [[QBChat instance] removeUserFromContactList:946391];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 5:
            switch (indexPath.row) {
                case 0:
                {
                    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                    extendedRequest[@"limit"] = @(100);
//                    extendedRequest[@"occupants_ids[all]"] = @"2960,3146,31478";
                    //
                    if(withContext){
                        [QBChat dialogsWithExtendedRequest:extendedRequest delegate:self context:testContext];
                    }else{
                        [QBChat dialogsWithExtendedRequest:extendedRequest delegate:self];
                    }
                }
                    break;
                    
                case 1:
                {
                    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                    extendedRequest[@"limit"] = @(100);
                    //
                    if(withContext){
                        [QBChat messagesWithDialogID:@"53c39cfbe4b077ddd43e95b2" extendedRequest:extendedRequest delegate:self context:testContext];
                    }else{
                        [QBChat messagesWithDialogID:@"53c39cfbe4b077ddd43e95b2" extendedRequest:extendedRequest delegate:self];
                    }
                }
                    break;
                    
                case 2:
                {
                    QBChatDialog *chatDialog = [QBChatDialog new];
                    chatDialog.name = @"World cup 2014";
                    chatDialog.occupantIDs = @[@(testUserID2)];
                    chatDialog.type = QBChatDialogTypeGroup;
                    //
                    if(withContext){
                        [QBChat createDialog:chatDialog delegate:self context:testContext];
                    }else{
                        [QBChat createDialog:chatDialog delegate:self];
                    }

                }
                    break;
                    
                case 3:
                {
                    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                    extendedRequest[@"pull_all[occupants_ids][]"] = @"3129";
                    extendedRequest[@"name"] = @"Team room 55";
                    //
                    if(withContext){
                        [QBChat updateDialogWithID:@"53c40525efa35756ae000027" extendedRequest:extendedRequest delegate:self context:testContext];
                    }else{
                        [QBChat updateDialogWithID:@"53c40525efa35756ae000027" extendedRequest:extendedRequest delegate:self];
                    }
                    
                }
                    break;
                    
                case 4:
                {
                    QBChatHistoryMessage *message = [QBChatHistoryMessage new];
                    message.ID = @"53aabe15e4b077ddd43e7fd3";
                    message.dialogID = @"53a99a7be4b094c7c6d31b41";
                    message.read = YES;
                    //
                    if(withContext){
                        [QBChat updateMessage:message delegate:self context:testContext];
                    }else{
                        [QBChat updateMessage:message delegate:self];
                    }
                }
                    break;
                    
                case 5:
                {
                    if(withContext){
                        [QBChat deleteMessageWithID:@"53a04938e4b0afa821474844" delegate:self context:testContext];
                    }else{
                        [QBChat deleteMessageWithID:@"53a04938e4b0afa821474844" delegate:self];
                    }
                }
                    break;
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - 
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        NSArray *dialogs = pagedResult.dialogs;
        NSLog(@"Dialogs: %@", dialogs);
        
    } else if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *messages = res.messages;
        NSLog(@"Messages: %@", messages);
        
    } else if (result.success && [result isKindOfClass:QBChatDialogResult.class]) {
        QBChatDialogResult *res = (QBChatDialogResult *)result;
        NSLog(@"Dilog: %@", res.dialog);
        
    }else{
        NSLog(@"result: %@", result);
    }
}

    
#pragma mark -
#pragma mark QBChatDelegate

#pragma mark Auth

-(void) chatDidLogin
{
    NSLog(@"Did login");
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
}

- (void)chatDidNotLogin
{
    NSLog(@"Did not login");
}

- (void)chatDidFailWithError:(NSInteger)code
{
    NSLog(@"Did Fail With Error code: %ld", (long)code);
}


#pragma mark 1-1 Messaging

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    NSLog(@"Did receive message: %@", message);
}


#pragma mark Group chat

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName
{
    NSLog(@"Did receive message: %@, from room %@", message, roomName);
}

- (void)chatRoomDidCreate:(NSString *)roomName
{
    NSLog(@"chatRoomDidCreate: %@", roomName);
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
    NSLog(@"chatRoomDidNotEnter: %@  %@", roomName, error);
}

- (void)chatRoomDidLeave:(NSString *)roomName
{
    NSLog(@"chatRoomDidLeave: %@", roomName);
    self.testRoom = nil;
}

- (void)chatRoomDidDestroy:(NSString *)roomName
{
    NSLog(@"chatRoomDidDestroy: %@", roomName);
}

- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName
{
    NSLog(@"chatRoomDidReceiveInformation %@, %@",roomName, information);
}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName
{
    NSLog(@"chatRoomDidChangeOnlineUsers %@, %@",roomName, onlineUsers);
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName
{
    NSLog(@"chatRoomDidReceiveListOfUsers %@, %@",roomName, users);
}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName
{
     NSLog(@"chatRoomDidReceiveListOfOnlineUsers %@, %@",roomName, users);
}

- (void)chatDidReceiveListOfRooms:(NSArray *)_rooms
{
    NSLog(@"Did receive list of rooms: %@", _rooms);
}


#pragma mark Group chat (Chat 2.0)

- (void)chatRoomDidEnter:(QBChatRoom *)room
{
    NSLog(@"Room did enter: %@", room);
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID
{
    NSLog(@"Did receive message: %@, from roomJID %@", message, roomJID);
}

- (void)chatRoomDidNotEnterRoomWithJID:(NSString *)roomJID error:(NSError *)error
{
    NSLog(@"Did not enter room with JID %@, error: %@", roomJID, error);
}

- (void)chatRoomDidLeaveRoomWithJID:(NSString *)roomJID
{
    NSLog(@"Room did leave with JID %@", roomJID);
}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers roomJID:(NSString *)roomJID
{
     NSLog(@"Room did change online users: %@, room JID: %@",onlineUsers, roomJID);
}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users roomJID:(NSString *)roomJID
{
    NSLog(@"Room did receive list of online users %@, room JID: %@",users, roomJID);
}


#pragma mark Contact list

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID
{
    NSLog(@"chatDidReceiveContactAddRequestFromUser %lu", (unsigned long)userID);
}

- (void)chatContactListDidChange:(QBContactList *)contactList
{
    if([contactList.contacts count] > 0 || [contactList.pendingApproval count] > 0){
        NSLog(@"contactList %@", contactList);
    }
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status
{
    NSLog(@"chatDidReceiveContactItemActivity, user: %lu, isOnline: %d, status: %@", (unsigned long)userID, isOnline, status);
}

    
@end
