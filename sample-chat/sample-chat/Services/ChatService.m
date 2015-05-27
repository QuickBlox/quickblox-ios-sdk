//
//  ChatService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/21/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "ChatService.h"

typedef void(^CompletionBlock)();
typedef void(^JoinRoomCompletionBlock)(QBChatRoom *);
typedef void(^CompletionBlockWithResult)(NSArray *);
typedef void(^RequestRoomsBlock)(NSArray *);

@interface ChatService () <QBChatDelegate>

@property (retain) NSTimer *presenceTimer;

@property (copy) CompletionBlock loginCompletionBlock;
@property (copy) JoinRoomCompletionBlock joinRoomCompletionBlock;
@property (copy) RequestRoomsBlock requestRoomsCompletionBlock;
@property (copy) CompletionBlock getDialogsCompletionBlock;

@end


@implementation ChatService

+ (instancetype)shared{
    static id instance_ = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

- (id)init{
    self = [super init];
    if(self){
        [[QBChat instance] addDelegate:self];
        //
        [QBChat instance].autoReconnectEnabled = YES;
        //
        [QBChat instance].streamManagementEnabled = YES;
        
        self.messages = [NSMutableDictionary dictionary];
    }
    return self;
}

- (QBUUser *)currentUser{
    return [[QBChat instance] currentUser];
}

- (void)loginWithUser:(QBUUser *)user completionBlock:(void(^)())completionBlock{
    self.loginCompletionBlock = completionBlock;
    
    [[QBChat instance] loginWithUser:user];
}

- (void)logout{
    [[QBChat instance] logout];
}

- (void)sendMessage:(QBChatMessage *)message{
    [[QBChat instance] sendMessage:message];
}

- (void)sendMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock{
    [[QBChat instance] sendMessage:message sentBlock:^(NSError *error) {
        sentBlock(error);
    }];
}

- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom{
    [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
}

- (void)joinRoom:(QBChatRoom *)room completionBlock:(void(^)(QBChatRoom *))completionBlock{
    self.joinRoomCompletionBlock = completionBlock;
    
    [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
}

- (void)leaveRoom:(QBChatRoom *)room{
    [[QBChat instance] leaveRoom:room];
}

- (void)setUsers:(NSMutableArray *)users
{
    _users = users;
    
    NSMutableDictionary *__usersAsDictionary = [NSMutableDictionary dictionary];
    for(QBUUser *user in users){
        [__usersAsDictionary setObject:user forKey:@(user.ID)];
    }
    
    _usersAsDictionary = [__usersAsDictionary copy];
}

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId{
    NSMutableArray *messages = [self.messages objectForKey:dialogId];
    if(messages == nil){
        messages = [NSMutableArray array];
        [self.messages setObject:messages forKey:dialogId];
    }
    
    return messages;
}

- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId{
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
        [messagesArray addObjectsFromArray:messages];
    }else{
        [self.messages setObject:messages forKey:dialogId];
    }
}

- (void)addMessage:(QBChatMessage *)message forDialogId:(NSString *)dialogId{
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
        [messagesArray addObject:message];
    }else{
        NSMutableArray *messages = [NSMutableArray array];
        [messages addObject:message];
        [self.messages setObject:messages forKey:dialogId];
    }
}

- (void)requestDialogsWithCompletionBlock:(void(^)())completionBlock{
    
    self.getDialogsCompletionBlock = completionBlock;
    
    [QBRequest dialogsWithSuccessBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs) {
        
        self.dialogs = dialogObjects.mutableCopy;
        
        [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:nil
                   successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                       
                       self.users = [users mutableCopy];
                       
                       if(self.getDialogsCompletionBlock != nil){
                           self.getDialogsCompletionBlock();
                           self.getDialogsCompletionBlock = nil;
                       }
                       
                   } errorBlock:nil];
        
    } errorBlock:nil];
}

- (void)requestDialogUpdateWithId:(NSString *)dialogId completionBlock:(void(^)())completionBlock{
    self.getDialogsCompletionBlock = completionBlock;
    
    [QBRequest dialogsForPage:nil
              extendedRequest:@{@"_id": dialogId}
                 successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
                     
                     BOOL found = NO;
                     NSArray *dialogsCopy = [NSArray arrayWithArray:self.dialogs];
                     for(QBChatDialog *dialog in dialogsCopy){
                         if([dialog.ID isEqualToString:dialogId]){
                             [self.dialogs removeObject:dialog];
                             found = YES;
                             break;
                         }
                     }
                     
                     [self.dialogs insertObject:dialogObjects.firstObject atIndex:0];
                     
                     if(!found){
                         [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:nil
                                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                                        
                                        [self.users addObjectsFromArray:users];
                                        
                                        if(self.getDialogsCompletionBlock != nil){
                                            self.getDialogsCompletionBlock();
                                            self.getDialogsCompletionBlock = nil;
                                        }
                                        
                                    } errorBlock:nil];
                     }else{
                         if(self.getDialogsCompletionBlock != nil){
                             self.getDialogsCompletionBlock();
                             self.getDialogsCompletionBlock = nil;
                         }
                     }
                     
                 } errorBlock:nil];
}


#pragma mark
#pragma mark QBChatDelegate

- (void)chatDidLogin{
    // Start sending presences
    [self.presenceTimer invalidate];
    self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                     target:[QBChat instance] selector:@selector(sendPresence)
                                   userInfo:nil repeats:YES];
    
    if(self.loginCompletionBlock != nil){
        self.loginCompletionBlock();
        self.loginCompletionBlock = nil;
    }
    
    if([self.delegate respondsToSelector:@selector(chatDidLogin)]){
        [self.delegate chatDidLogin];
    }
}

- (void)chatDidFailWithError:(NSInteger)code{
    // relogin here
    [[QBChat instance] loginWithUser:self.currentUser];
}

- (void)chatRoomDidEnter:(QBChatRoom *)room{
	if( self.joinRoomCompletionBlock != nil ){
		self.joinRoomCompletionBlock(room);
		self.joinRoomCompletionBlock = nil;
	}
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
    NSLog(@"Not entered!");
}

- (void)chatDidReceiveListOfRooms:(NSArray *)rooms{
    self.requestRoomsCompletionBlock(rooms);
    self.requestRoomsCompletionBlock = nil;
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    
    // notify observers
    BOOL processed = NO;
    if([self.delegate respondsToSelector:@selector(chatDidReceiveMessage:)]){
        processed = [self.delegate chatDidReceiveMessage:message];
    }
    
    if(!processed){
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"New message"
                                                       description:message.text
                                                              type:TWMessageBarMessageTypeInfo];
        
        [[SoundService instance] playNotificationSound];
        
        NSString *dialogId = message.customParameters[@"dialog_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDialogUpdatedNotification object:nil userInfo:@{@"dialog_id": dialogId}];
    }
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID{
    
    // notify observers
    BOOL processed = NO;
    if([self.delegate respondsToSelector:@selector(chatRoomDidReceiveMessage:fromRoomJID:)]){
        processed = [self.delegate chatRoomDidReceiveMessage:message fromRoomJID:roomJID];
    }
    
    if(!processed){
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"New message"
                                                       description:message.text
                                                              type:TWMessageBarMessageTypeInfo];
        
        [[SoundService instance] playNotificationSound];
    }
}


@end
