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
#define DefaultPrivacyListName @"public3"
#define TestMessage @"Hello world!"

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
        [[QBChat instance] addDelegate:self];
        [QBChat instance].useMutualSubscriptionForContactList = NO;
        //
        [QBChat instance].autoReconnectEnabled = YES;
        [QBChat instance].streamManagementEnabled = YES;
//        [QBChat instance].streamResumptionEnabled = YES;
        [QBChat instance].streamManagementSendMessageTimeout = 5;
        
        [QBSettings useTLSForChat:YES];
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
    
    self.dataSource = [[ChatDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
}


#pragma mark -
#pragma mark Notifications

- (void)didEnterBackground
{
    [[QBChat instance] logout];
}

- (void)willTerminate
{
    [[QBChat instance] logout];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    switch (indexPath.section) {
            
            // Sign In/Sign Out
        case 0:
            switch (indexPath.row) {
                    // Login
                case 0:{
                    QBUUser *user = [QBUUser user];
                    user.ID = [[ConfigManager sharedManager] testUserId1];
                    user.password =[[ConfigManager sharedManager] testUserPassword1];
                    
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
                    
                    [presenceTimer invalidate];
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
                    message.text = TestMessage;
                    
                    [message setRecipientID:[[ConfigManager sharedManager] testUserId2]];
                    
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    params[@"date_sent"] = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                    params[@"save_to_history"] = @YES;
                    params[@"data"] = @"{\"key1\": \"value1\", \"key2\": \"value2\"}";
                    [message setCustomParameters:params];
                    
                    QBChatAttachment *attachment = QBChatAttachment.new;
                    attachment.type = @"location";
                    attachment.url = @"https://qbprod.s3.amazonaws.com/5a8a3f91894144ef84d76ae98139c9a800";
                    QBChatAttachment *attachment2 = QBChatAttachment.new;
                    attachment2.type = @"video";
                    attachment2.ID = @"22";
                    [message setAttachments:@[attachment, attachment2]];
                
                    [[QBChat instance] sendMessage:message];
                }
                    break;
                    
                // send chat 1-1 message with 'sent' status
                case 1:{
                    QBChatMessage *message = [QBChatMessage message];
                    [message setText:[NSString stringWithFormat:@"Hello %d", rand()]];
                    [message setRecipientID:[[ConfigManager sharedManager] testUserId2]];

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
                    if(self.testRoom == nil){
                        self.testRoom = [[QBChatRoom alloc] initWithRoomJID:[[ConfigManager sharedManager] dialogJid]];
                    }
                    [self.testRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"1"}];
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
                    message.text = TestMessage;
                    //
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    params[@"save_to_history"] = @YES;
                    [message setCustomParameters:params];
                    //
                    QBChatAttachment *attachment2 = QBChatAttachment.new;
                    attachment2.type = @"video";
                    attachment2.ID = @"47863";
                    [message setAttachments:@[attachment2]];
                    //
                    
                    [[QBChat instance] sendChatMessage:message toRoom:self.testRoom];
                }
                    break;
                
                // Send message w\o join
                case 5:{
                    QBChatMessage *message = [QBChatMessage message];
                    message.text = TestMessage;
                    //
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    params[@"save_to_history"] = @YES;
                    [message setCustomParameters:params];
                    //
                    QBChatAttachment *attachment2 = QBChatAttachment.new;
                    attachment2.type = @"video";
                    attachment2.ID = @"47863";
                    [message setAttachments:@[attachment2]];
                    //
                    if(self.testRoom == nil){
                        self.testRoom = [[QBChatRoom alloc] initWithRoomJID:[[ConfigManager sharedManager] dialogJid]];
                    }
                    [self.testRoom sendMessageWithoutJoin:message];
                }
                break;
                
                // Send presence
                case 6:{
                    [[QBChat instance] sendPresenceWithParameters:@{@"job": @"manager", @"sex": @"man"} toRoom:_testRoom];
                }
                    break;
                    
                // Request all rooms
                case 7:{
                    [[QBChat instance] requestAllRooms];
                }
                    break;
                    
                    // Add users to room
                case 8:{
                    NSArray *users = [NSArray arrayWithObject:@([[ConfigManager sharedManager] testUserId2])];
                    
                    [[QBChat instance] addUsers:users toRoom:_testRoom];
                }
                    break;
                    
                    // Delete users from room
                case 9:{
                    NSArray *users = [NSArray arrayWithObject:@([[ConfigManager sharedManager] testUserId2])];
                    
                    [[QBChat instance] deleteUsers:users fromRoom:_testRoom];
                }
                    break;
                    
                    // Request room users
                case 10:{
//                    [[QBChat instance] requestRoomUsers:_testRoom];
                    [[QBChat instance] requestRoomUsersWithAffiliation:@"admin" room:_testRoom];
                }
                    break;
                    
                    // Request room online users
                case 11:{
                    QBChatRoom *_room = [[QBChatRoom alloc] initWithRoomJID:[[ConfigManager sharedManager] dialogJid]];
                    [_room requestOnlineUsers];
                }
                    break;
                    
                    // Request room information
                case 12:{
                     self.testRoom = [[QBChatRoom alloc] initWithRoomJID:[[ConfigManager sharedManager] dialogJid]];
                    [[QBChat instance] requestRoomInformation:_testRoom];
                }
                    break;
                    
                    // Destroy room
                case 13:{
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
                    [[QBChat instance] addUserToContactListRequest:[[ConfigManager sharedManager] testUserId2] sentBlock:^(NSError *error) {
                         NSLog(@"error: %@", error);
                    }];
                }
                    break;
                    
                    // Confirm add request
                case 1:{
                    [[QBChat instance] confirmAddContactRequest:[[ConfigManager sharedManager] testUserId2] sentBlock:^(NSError *error) {
                         NSLog(@"error: %@", error);
                    }];
                }
                    break;
                    
                    // Reject add request
                case 2:{
                    [[QBChat instance] rejectAddContactRequest:[[ConfigManager sharedManager] testUserId2] sentBlock:^(NSError *error) {
                         NSLog(@"error: %@", error);
                    }];
                }
                    break;
                    
                    // Remove user from contact list
                case 3:{
                    [[QBChat instance] removeUserFromContactList:[[ConfigManager sharedManager] testUserId2] sentBlock:^(NSError *error) {
                        NSLog(@"error: %@", error);
                    }];
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
                    if( useNewAPI ){
//                        NSMutableDictionary *extRequest = @{@"_id" : @"548184908a472ba18ddf5cd6"}.mutableCopy;
                        
                        QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
                        [QBRequest dialogsForPage:page extendedRequest:nil successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
                            
                            NSLog(@"dialogsForPage: %@", dialogObjects);
                            NSLog(@"dialogsUsersIDs: %@", dialogsUsersIDs);
                            NSLog(@"page: %@", page);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"dialogsForPage error: %@", response.error);
                        }];
                    }
                    else {
                        NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                        extendedRequest[@"limit"] = @(100);
                        
                        if(withQBContext){
                            [QBChat dialogsWithExtendedRequest:extendedRequest delegate:self context:testContext];
                        }else{
                            [QBChat dialogsWithExtendedRequest:extendedRequest delegate:self];
                        }
                    }
                }
                    break;
                    
                case 1:
                {
                    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                    extendedRequest[@"date_sent[gt]"] = @(1232);
                    QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:5 skip:0];
                    
                    if( useNewAPI ){
                        [QBRequest messagesWithDialogID:[[ConfigManager sharedManager] dialogId] extendedRequest:extendedRequest forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
                            NSLog(@"Messages: %@", messages);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"messagesWithDialogID error: %@", response.error);
                        }];
                    }
                    else{
			
                        if(withQBContext){
                            [QBChat messagesWithDialogID:[[ConfigManager sharedManager] dialogId] extendedRequest:extendedRequest delegate:self context:testContext];
                        }else{
                            [QBChat messagesWithDialogID:[[ConfigManager sharedManager] dialogId] extendedRequest:extendedRequest delegate:self];
                        }
                    }
                }
                    break;
                    
                case 2:
                {
                    QBChatDialog *chatDialog = [QBChatDialog new];
                    chatDialog.name = @"Smoky Mooo";
                    chatDialog.occupantIDs = @[@([[ConfigManager sharedManager] testUserId2])];
                    chatDialog.type = QBChatDialogTypeGroup;
                    chatDialog.photo = @"www.testlink.com";
                    chatDialog.data = @{@"class_name": @"dialog_data",
                                        @"age": @4};
                    
                    //
                    if( useNewAPI ){
                        [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                            NSLog(@"Success, dialog: %@", createdDialog);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"error create dialog: %@", response.error);
                        }];
                    }
                    else{
                        if( withQBContext ){
                            [QBChat createDialog:chatDialog delegate:self context:testContext];
                        }else{
                            [QBChat createDialog:chatDialog delegate:self];
                        }
                    }
                    
                }
                    break;
                    
                case 3:
                {
                    if ( useNewAPI ){
                        QBChatDialog *updateDialog = [[QBChatDialog alloc] initWithDialogID:[[ConfigManager sharedManager] dialogId]];
                        updateDialog.pushOccupantsIDs = @[@300, @301, @302];
                        updateDialog.photo = @"www.empty.com";
                        updateDialog.name = @"my name";
                        updateDialog.data = @{@"class_name": @"dialog_data",
                                              @"age": @33};
                        
                        [QBRequest updateDialog:updateDialog successBlock:^(QBResponse *responce, QBChatDialog *dialog) {
                            NSLog(@"Updated dialog: %@", dialog);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"Error while updating dialog: %@", response.error);
                        }];
                    }
                    else{
                        NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
                        extendedRequest[@"pull_all[occupants_ids][]"] = @"301";
                        extendedRequest[@"name"] = @"Team22";
                        extendedRequest[@"photo"] = @"yeahhh22";
                        
                        if(withQBContext){
                            [QBChat updateDialogWithID:[[ConfigManager sharedManager] dialogId] extendedRequest:extendedRequest delegate:self context:testContext];
                        }else{
                            [QBChat updateDialogWithID:[[ConfigManager sharedManager] dialogId] extendedRequest:extendedRequest delegate:self];
                        }
                    }
                    
                }
                    break;
                    
                case 4: 
                {
                    if (useNewAPI) {
                        [QBRequest deleteDialogWithID:@"54fda689535c125b0700bbfa" successBlock:^(QBResponse *responce) {
                            NSLog(@"dialog was deleted");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"error: %@", response.error);
                        }];
                    } else {
                        if(withQBContext){
                            [QBChat deleteDialogWithID:[[ConfigManager sharedManager] dialogId] delegate:self context:testContext];
                        }else{
                            [QBChat deleteDialogWithID:[[ConfigManager sharedManager] dialogId] delegate:self];
                        }
                    }
                }
                    break;
                    
                case 5:
                {
                    
                    QBChatHistoryMessage *msg = [[QBChatHistoryMessage alloc] init];
                    msg.dialogID = @"54fda666535c12834e06b108";
                    msg.text = @"Test message";
                    msg.recipientID = 2394285;
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

                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    params[@"name"] = @"Igor";
                    [msg setCustomParameters:params];
                    
                    if( useNewAPI ){
                        [QBRequest createMessage:msg successBlock:^(QBResponse *response, QBChatHistoryMessage *createdMessage) {
                            NSLog(@"success: %@", createdMessage);
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"ERROR: %@", response.error);
                        }];
                    }
                    else {
                        if( withQBContext ){
                            [QBChat createMessage:msg delegate:self context:testContext];
                        }else{
                            [QBChat createMessage:msg delegate:self];
                        }
                    }
        
                    
                }
                    break;
                    
                case 6:
                {
                    QBChatHistoryMessage *message = [QBChatHistoryMessage new];
                    message.ID = @"54fdbb69535c12c2e407c672";
                    message.dialogID = @"54fda666535c12834e06b108";
                    message.read = YES;
                    //
                    if( useNewAPI ){
                        [QBRequest updateMessage:message successBlock:^(QBResponse *response) {
                            NSLog(@"success");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"ERROR: %@", response.error);
                        }];
                    }
                    else{
                        
                        if( withQBContext ){
                            [QBChat updateMessage:message delegate:self context:testContext];
                        }else{
                            [QBChat updateMessage:message delegate:self];
                        }
                    }
                    
                }
                    break;
                    
                case 7:
                {
                    NSString *dialogID = @"54fda666535c12834e06b108";
                    
                    if( useNewAPI ){
                        NSSet *mesagesIDs = [NSSet setWithObjects:@"54fdbb69535c12c2e407c672", @"54fdbb69535c12c2e407c673", nil];
                        
                        [QBRequest markMessagesAsRead:mesagesIDs dialogID:dialogID successBlock:^(QBResponse *response) {
                            NSLog(@"sucess");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"markMessagesAsRead error %@", response.error);
                        }];
                    }else{
                        NSArray *mesagesIDs = [NSArray arrayWithObjects:@"54fdbb69535c12c2e407c672", @"54fdbb69535c12c2e407c673", nil];
                        
                        if( withQBContext ){
                            [QBChat markMessagesAsRead:mesagesIDs dialogID:dialogID delegate:self context:testContext];
                        }else{
                            [QBChat markMessagesAsRead:mesagesIDs dialogID:dialogID delegate:self];
                        }
                    }
                }
                    break;
                    
                case 8:
                {
                    if( useNewAPI ){
                        NSSet *mesagesIDs = [NSSet setWithObjects:@"54fdbb69535c12c2e407c672", @"54fdbb69535c12c2e407c673", nil];
                        
                        [QBRequest deleteMessagesWithIDs:mesagesIDs successBlock:^(QBResponse *response) {
                            NSLog(@"success");
                        } errorBlock:^(QBResponse *response) {
                            NSLog(@"deleteMessageWithID error:%@", response.error);
                        }];
                    }
                    else{
                        if( withQBContext ){
                            [QBChat deleteMessageWithID:@"53a04938e4b0afa821474844" delegate:self context:testContext];
                        }else{
                            [QBChat deleteMessageWithID:@"53a04938e4b0afa821474844" delegate:self];
                        }
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
                    
                    QBPrivacyItem *item = [[QBPrivacyItem alloc] initWithType:USER_ID valueForType:[[ConfigManager sharedManager] testUserId2] action:DENY];
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
                    QBPrivacyItem *item = [[QBPrivacyItem alloc] initWithType:USER_ID valueForType:[[ConfigManager sharedManager] testUserId2] action:DENY];
                    QBPrivacyList *list = [[QBPrivacyList alloc] initWithName:DefaultPrivacyListName items:@[item]];
                    [[QBChat instance] setPrivacyList:list];
                    
                }
                    break;
                    
                //unblock user
                case 3:
                {
                    QBPrivacyItem *item = [[QBPrivacyItem alloc] initWithType:USER_ID valueForType:[[ConfigManager sharedManager] testUserId2] action:ALLOW];
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
                    [[QBChat instance] sendUserIsTypingToUserWithID:[[ConfigManager sharedManager] testUserId2]];
                }
                    break;
                    //send stop typing
                case 1:
                {
                    [[QBChat instance] sendUserStopTypingToUserWithID:[[ConfigManager sharedManager] testUserId2]];
                }
                    break;
            }
            break;
        case 8:{
            QBChatMessage *mess = [QBChatMessage markableMessage];
            mess.text = @"markable message";
            [mess setRecipientID:[[ConfigManager sharedManager] testUserId2]];
            [[QBChat instance] sendMessage:mess];
        }
            break;
            
        case 9:
            switch (indexPath.row) {
                    // enable carbons
                case 0:
                {
                    [[QBChat instance] setCarbonsEnabled:YES];
                }
                    break;
                    // disable carbons
                case 1:
                {
                    [[QBChat instance] setCarbonsEnabled:NO];
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

- (void)completedWithResult:(QBResult *)result
{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        NSArray *dialogs = pagedResult.dialogs;
        NSLog(@"Dialogs: %d", dialogs.count);
        
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
}


#pragma mark -
#pragma mark QBChatDelegate

#pragma mark Auth

-(void) chatDidLogin
{
    NSLog(@"Did login");

//    [presenceTimer invalidate];
//    presenceTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
//    [[QBChat instance] setCarbonsEnabled:YES];
    
//    [[QBChat instance] requestServiceDiscoveryInformation];
}

- (void)chatDidNotLogin
{
    NSLog(@"Did not login");
}

- (void)chatDidFailWithError:(NSInteger)code
{
    NSLog(@"Did Fail With Error code: %ld", (long)code);
    [presenceTimer invalidate];
}

- (void)chatDidReceiveServiceDiscoveryInformation:(NSArray *)features
{
    
}

#pragma mark 1-1 Messaging

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    NSLog(@"Did receive message: %@", message);
    
    // Read message if need
    //
    if([message markable]){
        [[QBChat instance] readMessage:message];
    }
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message error:(NSError *)error
{
    NSLog(@"Did not send message: %@, error: %@", message, error);
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
    if(self.testRoom == nil){
        self.testRoom = room;
    }
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
    NSLog(@"contactList %@", contactList);
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


#pragma mark -
#pragma mark Typing Status

- (void)chatDidReceiveUserIsTypingFromUserWithID:(NSUInteger)userID{
    NSLog(@"chatDidReceiveUserIsTypingFromUserWithID: %lu", (unsigned long)userID);

}

- (void)chatDidReceiveUserStopTypingFromUserWithID:(NSUInteger)userID{
    NSLog(@"chatDidReceiveUserStopTypingFromUserWithID: %lu", (unsigned long)userID);

}


#pragma mark -
#pragma mark Delivered status

- (void)chatDidDeliverMessageWithID:(NSString *)messageID{
    NSLog(@"chatDidDeliverMessageWithID: %@", messageID);
}


#pragma mark -
#pragma mark Read status

- (void)chatDidReadMessageWithID:(NSString *)messageID{
    NSLog(@"chatDidReadMessageWithID: %@", messageID);
}

@end
