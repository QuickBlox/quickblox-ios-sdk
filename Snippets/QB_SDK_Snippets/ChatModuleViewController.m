//
//  ChatModuleViewController.m
//  QB_SDK_Snippets
//
//  Created by kirill on 8/7/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import "ChatModuleViewController.h"
#import "ChatDataSource.h"

#define testRoomName @"meetingroom2"

#define ADMIN_ID 103894

#define DefaultPrivacyListName @"public2"

@interface ChatModuleViewController () <QBActionStatusDelegate,UITableViewDelegate, QBChatDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) ChatDataSource *dataSource;

@property (strong, nonatomic) QBChatRoom *testRoom;
@property (strong, nonatomic) QBChatRoom *testRoom2;

@end

@implementation ChatModuleViewController{
    NSTimer *presenceTimer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Chat", @"Chat");
        self.tabBarItem.image = [UIImage imageNamed:@"circle.png"];
        
        // set Chat delegate
        [[QBChat instance] setDelegate:self];
//        [QBSettings useTLSForChat:YES];
//        [QBSettings useStreamManagementForChat:YES];
        [QBChat instance].useMutualSubscriptionForContactList = NO;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    self.dataSource = [[ChatDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
}


#pragma mark -
#pragma mark Notifications

- (void)didEnterBackground
{
    [[QBChat instance] logout];
}

static BOOL done = NO;

- (void)willTerminate
{
    [[QBChat instance] logout];
}

- (void)willEnterForeground
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
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
                    
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    params[@"date_sent"] = @((int)[[NSDate date] timeIntervalSince1970]);
                    params[@"save_to_history"] = @YES;
                    params[@"param1"] = @"value1";
                    params[@"param2"] = @"value2";
                    [message setCustomParameters:params];
                    //                    QBChatAttachment *attachment = QBChatAttachment.new;
                    //                    attachment.type = @"image";
                    //                    attachment.ID = @"47863";
                    //                    [message setAttachments:@[attachment]];
                    //
                    
                    [[QBChat instance] sendMessage:message];
                }
                    break;
                    
                // send chat 1-1 message with 'sent' status
                case 1:{
                    QBChatMessage *message = [QBChatMessage message];
                    [message setText:[NSString stringWithFormat:@"banana%d 😄", rand()]];
                    [message setRecipientID:UserID2];

                    [[QBChat instance] sendMessage:message sentBlock:^(NSError *error) {
                        NSLog(@"message: %@, sent: %d", message.text, error == nil);
                    }];
                }
                    break;
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
                    [[QBChat instance] leaveRoom:_testRoom];
                }
                    break;
                    
                    // Send message
                case 4:{
                    QBChatMessage *message = [QBChatMessage message];
                    [message setText:[NSString stringWithFormat:@"banana%d 1279282 test", rand()]];
                    //
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    //                    params[@"date_sent"] = @((int)[[NSDate date] timeIntervalSince1970]);
                    params[@"save_to_history"] = @YES;
//                    params[@"dialog_id"] = @"231231211";
                    [message setCustomParameters:params];
                    //                    QBChatAttachment *attachment = QBChatAttachment.new;
                    //                    attachment.type = @"image";
                    //                    attachment.ID = @"47863";
                    //                    [message setAttachments:@[attachment]];
                    //
                    QBChatAttachment *attachment2 = QBChatAttachment.new;
                    attachment2.type = @"video";
                    attachment2.ID = @"47863";
                    [message setAttachments:@[attachment2]];
                    //
                    [[QBChat instance] sendChatMessage:message toRoom:_testRoom];
                }
                    break;
                    
                    // Send presence
                case 5:{
                    [[QBChat instance] sendPresenceWithParameters:@{@"job": @"manager", @"sex": @"man"} toRoom:_testRoom];
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
                    
                    [[QBChat instance] addUsers:users toRoom:_testRoom];
                }
                    break;
                    
                    // Delete users from room
                case 8:{
                    NSNumber *user = [NSNumber numberWithInt:1279283];
                    NSArray *users = [NSArray arrayWithObject:user];
                    
                    [[QBChat instance] deleteUsers:users fromRoom:_testRoom];
                }
                    break;
                    
                    // Request room users
                case 9:{
                    [[QBChat instance] requestRoomUsers:_testRoom];
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
                     self.testRoom = [[QBChatRoom alloc] initWithRoomJID:testRoomJID];
                    [[QBChat instance] requestRoomInformation:_testRoom];
                }
                    break;
                    
                    // Destroy room
                case 12:{
                    [[QBChat instance] destroyRoom:_testRoom];
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
                    if(withQBContext){
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
                    if(withQBContext){
                        [QBChat messagesWithDialogID:@"53edaff0535c1227d9008d34" extendedRequest:extendedRequest delegate:self context:testContext];
                    }else{
                        [QBChat messagesWithDialogID:@"53edaff0535c1227d9008d34" extendedRequest:extendedRequest delegate:self];
                    }
                }
                    break;
                    
                case 2:
                {
                    QBChatDialog *chatDialog = [QBChatDialog new];
                    chatDialog.name = @"World cup 2014 😄";
                    chatDialog.occupantIDs = @[@(UserID2)];
                    chatDialog.type = QBChatDialogTypeGroup;
                    chatDialog.photo = @"www.com";
                    //
                    if(withQBContext){
                        [QBChat createDialog:chatDialog delegate:self context:testContext];
                    }else{
                        [QBChat createDialog:chatDialog delegate:self];
                    }
                    
                }
                    break;
                    
                case 3:
                {
                    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                    extendedRequest[@"push_all[occupants_ids][]"] = @"292";
                    extendedRequest[@"name"] = @"Team ee room 55";
                    extendedRequest[@"photo"] = @"11111";
                    
                    //
                    if(withQBContext){
                        [QBChat updateDialogWithID:@"53edaff0535c1227d9008d34" extendedRequest:extendedRequest delegate:self context:testContext];
                    }else{
                        [QBChat updateDialogWithID:@"53edaff0535c1227d9008d34" extendedRequest:extendedRequest delegate:self];
                    }
                    
                }
                    break;
                    
                case 4:
                {
                    QBChatHistoryMessage *msg = [[QBChatHistoryMessage alloc] init];
                    msg.dialogID = @"53db8798535c125e8e000902";
                    msg.text = @"hello amigo";
                    msg.recipientID = 1022637;
                    //
                    QBChatAttachment *attachment = QBChatAttachment.new;
                    attachment.type = @"image";
                    attachment.ID = @"47863";
                    attachment.url = @"www.com";
                    //
                    QBChatAttachment *attachment2 = QBChatAttachment.new;
                    attachment2.type = @"image";
                    attachment2.ID = @"47863";
                    attachment2.url = @"www.com";
                    //
                    [msg setAttachments:@[attachment, attachment2]];
                    //
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    params[@"name"] = @"Igor";
                    params[@"age"] = @(4);
                    [msg setCustomParameters:params];
                    
                    if(withQBContext){
                        [QBChat createMessage:msg delegate:self context:testContext];
                    }else{
                        [QBChat createMessage:msg delegate:self];
                    }
                }
                    break;
                    
                case 5:
                {
                    QBChatHistoryMessage *message = [QBChatHistoryMessage new];
                    message.ID = @"53aabe15e4b077ddd43e7fd3";
                    message.dialogID = @"53a99a7be4b094c7c6d31b41";
                    message.read = YES;
                    //
                    if(withQBContext){
                        [QBChat updateMessage:message delegate:self context:testContext];
                    }else{
                        [QBChat updateMessage:message delegate:self];
                    }
                }
                    break;
                    
                case 6:
                {
                    NSString *dialogID = @"53d10eede4b02f496c21549f";
                    NSArray *mesagesIDs = @[@"53aabe15e4b077ddd43e7fd3", @"53aabe15e4b077ddd43e7fd7"];
                    mesagesIDs = nil;
                    //
                    if(withQBContext){
                        [QBChat markMessagesAsRead:mesagesIDs dialogID:dialogID delegate:self context:testContext];
                    }else{
                        [QBChat markMessagesAsRead:mesagesIDs dialogID:dialogID delegate:self];
                    }
                }
                    break;
                    
                case 7:
                {
                    if(withQBContext){
                        [QBChat deleteMessageWithID:@"53a04938e4b0afa821474844" delegate:self context:testContext];
                    }else{
                        [QBChat deleteMessageWithID:@"53a04938e4b0afa821474844" delegate:self];
                    }
                }
                    break;
            }
            break;
        case 6:
            if( [[QBChat instance] isLoggedIn ]== NO ){
                NSLog(@"You need to login and create a session with user");
                break;
            }
            switch (indexPath.row) {
                //set (create) privacy list
                case 0:
                {
                    
                    QBPrivacyItem *item = [[QBPrivacyItem alloc] initWithType:USER_ID valueForType:UserID2 action:DENY];
                    QBPrivacyList *list = [[QBPrivacyList alloc] initWithName:DefaultPrivacyListName items:@[item]];
                    [[QBChat instance] setPrivacyList:list];
                }
                    break;
                
                //remove privacy list
                case 1:{
                    
                    [[QBChat instance] removePrivacyListWithName:DefaultPrivacyListName];
                }
                    break;
                
                //block user 2
                case 2:
                {
                    QBPrivacyItem *item = [[QBPrivacyItem alloc] initWithType:USER_ID valueForType:UserID2 action:DENY];
                    QBPrivacyList *list = [[QBPrivacyList alloc] initWithName:DefaultPrivacyListName items:@[item]];
                    [[QBChat instance] setPrivacyList:list];
                    
                }
                    break;
                    
                //unblock user
                case 3:
                {
                    QBPrivacyItem *item = [[QBPrivacyItem alloc] initWithType:USER_ID valueForType:UserID2 action:ALLOW];
                    QBPrivacyList *list = [[QBPrivacyList alloc] initWithName:DefaultPrivacyListName items:@[item]];
                    [[QBChat instance] setPrivacyList:list];
                }
                    break;
                    
                //get list names
                case 4:
                {
                    [[QBChat instance] retrievePrivacyListNames];
                }
                    break;
                    
                //get public list
                case 5:
                {
                    [[QBChat instance] retrievePrivacyListWithName:DefaultPrivacyListName];
                }
                    break;
                    
                //set list "public" as default
                case 6:
                {
                    [[QBChat instance] setDefaultPrivacyListWithName:DefaultPrivacyListName];
                }
                    break;
            }
            break;
        case 7:
            switch (indexPath.row) {
                    //send typing
                case 0:
                {
                    [[QBChat instance] sendUserIsTypingToUserWithID:UserID2];
                }
                    break;
                    //send stop typing
                case 1:
                {
                    [[QBChat instance] sendUserStopTypingToUserWithID:UserID2];
                }
                    break;
            }
            break;
        case 8:{
            QBChatMessage *mess = [QBChatMessage markableMessage];
            mess.text = @"markable message";
            [mess setRecipientID:UserID2];
            [[QBChat instance] sendMessage:mess];
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
        NSLog(@"Dialog: %@", res.dialog);
        
    } else if (result.success && [result isKindOfClass:QBChatMessageResult.class]) {
        QBChatMessageResult *res = (QBChatMessageResult *)result;
        NSLog(@"Message: %@", res.message);
        
    }else{
        NSLog(@"result: %@", result);
    }
    
    done = YES;
}


#pragma mark -
#pragma mark QBChatDelegate

#pragma mark Auth

-(void) chatDidLogin
{
    NSLog(@"Did login");
    
    [presenceTimer invalidate];
    presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

- (void)chatDidNotSendMessage:(QBChatMessage *)message
{
      NSLog(@"Did not send message: %@", message);
}


#pragma mark Group chat

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName
{
//    NSLog(@"Did receive message: %@, from room %@", message, roomName);
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
    self.testRoom = room;
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

#pragma mark Privacy

- (void)chatDidSetPrivacyListWithName:(NSString *)name{
    NSLog(@"chatDidSetPrivacyListWithName %@", name);
    NSLog(@"if you created 'public' list and you want the rules to be applied then you need to make public list active'");
}

- (void)chatDidRemovedPrivacyListWithName:(NSString *)name{
    NSLog(@"chatDidRemovedPrivacyListWithName %@", name);
}

- (void)chatDidSetActivePrivacyListWithName:(NSString *)name{
    NSLog(@"chatDidSetActivePrivacyListWithName %@", name);
}

- (void)chatDidSetDefaultPrivacyListWithName:(NSString *)name{
    NSLog(@"chatDidSetDefaultPrivacyListWithName %@", name);
}

- (void)chatDidReceivePrivacyListNames:(NSArray *)listNames{
    NSLog(@"chatDidReceivePrivacyListNames: %@", listNames);
}

- (void)chatDidReceivePrivacyList:(QBPrivacyList *)privacyList{
    NSLog(@"chatDidReceivePrivacyList: %@", privacyList);
}

- (void)chatDidNotReceivePrivacyListWithName:(NSString *)name error:(id)error{
    NSLog(@"chatDidNotReceivePrivacyListWithName: %@ due to error:%@", name, error);
}

- (void)chatDidNotSetPrivacyListWithName:(NSString *)name error:(id)error{
    NSLog(@"chatDidNotSetPrivacyListWithName: %@ due to error:%@", name, error);
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message error:(NSError *)error{
    NSLog(@"chatDidNotSendMessage: %@ \nerror:%@", message, error);
}

#pragma mark -
#pragma mark Typing Status

- (void)chatDidReceiveUserIsTypingFromUserWithID:(NSUInteger)userID{
    NSLog(@"chatDidReceiveUserIsTypingFromUserWithID: %lu", (unsigned long)userID);

}

- (void)chatDidReceiveUserStopTypingFromUserWithID:(NSUInteger)userID{
    NSLog(@"chatDidReceiveUserStopTypingFromUserWithID: %lu", (unsigned long)userID);

}

#pragma mark -
#pragma mark Chat Status

- (void)chatDidDeliverMessageWithPacketID:(NSString *)packetID{
    NSLog(@"chatDidDeliverMessageWithPacketID: %@", packetID);
}

@end
