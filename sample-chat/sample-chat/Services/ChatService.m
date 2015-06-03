//
//  ChatService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/21/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "ChatService.h"

typedef void(^CompletionBlock)();
typedef void(^CompletionBlockWithResult)(NSArray *);

@interface ChatService () <QBChatDelegate>

@property (copy) CompletionBlock loginCompletionBlock;
@property (copy) CompletionBlock getDialogsCompletionBlock;

@end


@implementation ChatService


#pragma mark
#pragma mark Init

+ (instancetype)shared
{
    static id instance_ = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

- (id)init
{
    self = [super init];
    if(self){
        [[QBChat instance] addDelegate:self];
        //
        [QBChat instance].autoReconnectEnabled = YES;
        //
        [QBChat instance].streamManagementEnabled = YES;
        [QBChat instance].streamResumptionEnabled = YES;
        
        self.messages = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark
#pragma mark Login/Logout

- (void)loginWithUser:(QBUUser *)user completionBlock:(void(^)())completionBlock
{
    self.loginCompletionBlock = completionBlock;
    
    [[QBChat instance] loginWithUser:user];
}

- (void)logout
{
    [[QBChat instance] logout];
}


#pragma mark
#pragma mark Send message

- (void)sendMessage:(NSString *)messageText toDialog:(QBChatDialog *)dialog
{
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = messageText;
    [message setCustomParameters:[@{@"save_to_history": @YES} mutableCopy]];
    
    // send a message
    if(dialog.type == QBChatDialogTypePrivate){
        // save message to inmemory db
        message.senderID = [QBSession currentSession].currentUser.ID;
        [self addMessage:message forDialogId:dialog.ID];
    }
    [dialog sendMessage:message];
    
    // update dialog
    dialog.lastMessageUserID = [QBSession currentSession].currentUser.ID;
    dialog.lastMessageText = messageText;
    dialog.lastMessageDate = message.dateSent;
}


#pragma mark
#pragma mark Request dialogs

- (void)requestDialogsWithCompletionBlock:(void(^)())completionBlock
{
    self.getDialogsCompletionBlock = completionBlock;
    
    [QBRequest dialogsWithSuccessBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs) {
        
        // save dialogs in memory
        //
        self.dialogs = dialogObjects.mutableCopy;
        
        // join all group dialogs
        //
        for(QBChatDialog *dialog in self.dialogs){
            if(dialog.type != QBChatDialogTypePrivate){
                [dialog setOnJoin:^() {
                    NSLog(@"Dialog joined");
                }];
                [dialog setOnJoinFailed:^(NSError *error) {
                    NSLog(@"Join Fail, error: %@", error);
                }];
                [dialog join];
            }
        }
        
        
        // get dialogs' users
        //
        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
        [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:page
                   successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                       
                       if(page.totalEntries > page.perPage){
                           // TODO: implement pagination
                           
                       }
                       
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
                     
                     QBChatDialog *updatedDialog = dialogObjects.firstObject;
                     [self.dialogs insertObject:updatedDialog atIndex:0];
                     [_dialogsAsDictionary setObject:updatedDialog forKey:updatedDialog.ID];
                     
                     if(!found){
                         [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:nil
                                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                                        
                                        [self.users addObjectsFromArray:users];
                                        for(QBUUser *user in users){
                                            [_usersAsDictionary setObject:user forKey:@(user.ID)];
                                        }
                                        
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
#pragma mark Local storage

- (void)setUsers:(NSMutableArray *)users
{
    _users = users;
    
    if(users != nil && users.count > 0){
        NSMutableDictionary *__usersAsDictionary = [NSMutableDictionary dictionary];
        for(QBUUser *user in users){
            [__usersAsDictionary setObject:user forKey:@(user.ID)];
        }
        
        _usersAsDictionary = [__usersAsDictionary mutableCopy];
    }
}

- (void)setDialogs:(NSMutableArray *)dialogs
{
    _dialogs = dialogs;
    
    if(dialogs != nil && dialogs.count > 0){
        NSMutableDictionary *__dialogsAsDictionary = [NSMutableDictionary dictionary];
        for(QBUUser *dialog in dialogs){
            [__dialogsAsDictionary setObject:dialog forKey:@(dialog.ID)];
        }
        
        _dialogsAsDictionary = [__dialogsAsDictionary mutableCopy];
    }
}

- (NSMutableArray *)messagsForDialogId:(NSString *)dialogId
{
    NSMutableArray *messages = [self.messages objectForKey:dialogId];
    if(messages == nil){
        messages = [NSMutableArray array];
        [self.messages setObject:messages forKey:dialogId];
    }
    
    return messages;
}

- (void)addMessages:(NSArray *)messages forDialogId:(NSString *)dialogId
{
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
        [messagesArray addObjectsFromArray:messages];
    }else{
        [self.messages setObject:messages forKey:dialogId];
    }
}

- (void)addMessage:(QBChatMessage *)message forDialogId:(NSString *)dialogId
{
    NSMutableArray *messagesArray = [self.messages objectForKey:dialogId];
    if(messagesArray != nil){
        [messagesArray addObject:message];
    }else{
        NSMutableArray *messages = [NSMutableArray array];
        [messages addObject:message];
        [self.messages setObject:messages forKey:dialogId];
    }
}


#pragma mark
#pragma mark QBChatDelegate

- (void)chatDidLogin
{
    if(self.loginCompletionBlock != nil){
        self.loginCompletionBlock();
        self.loginCompletionBlock = nil;
    }
    
    if([self.delegate respondsToSelector:@selector(chatDidLogin)]){
        [self.delegate chatDidLogin];
    }
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    [self processMessage:message];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID
{
    [self processMessage:message];
}

- (void)processMessage:(QBChatMessage *)message{
    NSString *dialogId = message.customParameters[@"dialog_id"];
    
    // save message to local storage
    //
    [self addMessage:message forDialogId:dialogId];
    
    // update dialogs in a local storage
    //
    QBChatDialog *dialog = self.dialogsAsDictionary[dialogId];
    if(dialog != nil){
        dialog.lastMessageUserID = message.senderID;
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = message.dateSent;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDialogsUpdated object:nil];
    }else{
        [self requestDialogUpdateWithId:dialogId completionBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDialogsUpdated object:nil];
        }];
    }
    
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
    }
}


#pragma mark
#pragma mark Utils

- (void)sortDialogs
{
    [self.dialogs sortUsingComparator:^NSComparisonResult(QBChatDialog *obj1, QBChatDialog *obj2) {
        NSDate *first = obj1.lastMessageDate;
        NSDate *second = obj2.lastMessageDate;
        return [second compare:first];
    }];
}


@end
