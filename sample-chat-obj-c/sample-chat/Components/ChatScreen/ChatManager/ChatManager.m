//
//  ChatManager.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatManager.h"
#import <Quickblox/Quickblox.h>
#import "ChatStorage.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "ChatManager+InfoMessages.h"
#import "QBChatMessage+Chat.h"
#import "QBUUser+Chat.h"

static NSString* const kChatServiceDomain = @"com.q-municate.chatservice";
static NSUInteger const kUsersLimit = 100;

typedef void(^DialogsIterationHandler)(QBResponse *response,
                                       NSArray<QBChatDialog *> *objects,
                                       NSSet<NSNumber *> *usersIDs, Boolean stop);
typedef void(^DialogsPage)(QBResponsePage *page);
typedef void(^UsersPage)(QBGeneralResponsePage *page);

@interface ChatManager () <QBChatDelegate>
@end

@implementation ChatManager
//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.storage = [[ChatStorage alloc] init];
        self.draftMessages = [NSMutableSet set];
        [QBChat.instance addDelegate: self];
    }
    return self;
}

//Shared Instance
+ (instancetype)instance {
    static ChatManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - Public Methods
- (void)updateStorage {
    if ([self.delegate respondsToSelector:@selector(chatManagerWillUpdateStorage:)]) {
        [self.delegate chatManagerWillUpdateStorage:self];
    }
    if (QBChat.instance.isConnected == NO) {
        if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
            [self.delegate chatManager:self didFailUpdateStorage:@"Connection network error, please try again"];
        }
        return;
    }
    __block NSString *message;
    [self updateAllDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil completion:^(QBResponse *response) {
        if (response.error.error) {
            message = [self errorMessageWithResponse:response];
        }
        if (message) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                [self.delegate chatManager:self didFailUpdateStorage:message];
            }
        }
    }];
}

// MARK: - Dialogs
- (void)createPrivateDialogWithOpponent:(QBUUser *)opponent
                             completion:(nullable DialogCompletion)completion {
    NSAssert(opponent.ID > 0, @"Incorrect user ID");
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull == NO) {
        return;
    }
    NSInteger currentUserID = profile.ID;
    QBChatDialog *localDialog = [self.storage privateDialogWithOpponentID:opponent.ID];
    if (localDialog) {
        localDialog.updatedAt = [NSDate now];
        [self.storage updateDialogs:@[localDialog] completion:^(NSError * _Nullable error) {
            if (completion) {
                completion(nil, localDialog);
            }
        }];
    } else {
        QBChatDialog *dialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
        dialog.occupantIDs = @[@(opponent.ID), @(currentUserID)];
        [QBRequest createDialog:dialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull createdDialog) {
            [self.storage updateDialogs:@[createdDialog] completion:^(NSError * _Nullable error) {
                //Notify about create new dialog
                NSString *message = [NSString stringWithFormat:@"%@%@", @"created the private chat ", createdDialog.name];
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                    [self.delegate chatManager:self didUpdateStorage:message];
                }
                if (completion) {
                    completion(error, createdDialog);
                }
            }];
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (completion) {
                completion(response.error.error, nil);
            }
        }];
    }
}

- (void)createGroupDialogWithName:(NSString *)name
                        occupants:(NSArray<QBUUser *> *)occupants
                       completion:(nullable DialogCompletion)completion {
    NSMutableSet *occupantIDs = [NSMutableSet set];
    for (QBUUser *user in occupants) {
        NSAssert([user isKindOfClass:[QBUUser class]], @"occupants must be an array of QBUUser instances");
        [occupantIDs addObject:@(user.ID)];
    }
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = name;
    chatDialog.occupantIDs = occupantIDs.allObjects;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull dialog) {
        [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
            if (error) {
                Log(@"%@ dialog join error: %@",NSStringFromClass([ChatManager class]), error.localizedDescription);
            }
            //Notify about create new dialog
            [self sendCreateToDialog:dialog completionBlock:^(NSError * _Nullable error) {
                if (error) {
                    Log(@"%@ send Create To Dialog error: %@",NSStringFromClass([ChatManager class]), error.localizedDescription);
                }
                [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                    NSString *infoMessage = [NSString stringWithFormat:@"%@%@", @"created the group chat ", dialog.name];
                    if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                        [self.delegate chatManager:self didUpdateStorage:infoMessage];
                    }
                    completion(error, dialog);
                }];
            }];
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response.error.error, nil);
        }
    }];
}

- (void)leaveDialogWithID:(NSString *)dialogId completion:(nullable MessagesErrorHandler)completion {
    Profile *currentUser = [[Profile alloc] init];
    if (currentUser.isFull == NO) {
        return;
    }
    QBChatDialog *dialog = [self.storage  dialogWithID:dialogId];
    NSSet *dialogsWithIDs = [NSSet setWithArray:@[dialogId]];
    
    if (!dialog || dialog.type == QBChatDialogTypePublicGroup) {
        if (completion) {
            completion(@"Dialog doesn't exist");
        }
        return;
    }
    
    if (dialog.type == QBChatDialogTypePrivate) {
        [QBRequest deleteDialogsWithIDs:dialogsWithIDs forAllUsers:NO successBlock:^(QBResponse * _Nonnull response, NSArray<NSString *> * _Nonnull deletedObjectsIDs, NSArray<NSString *> * _Nonnull notFoundObjectsIDs, NSArray<NSString *> * _Nonnull wrongPermissionsObjectsIDs) {
            [self.storage deleteDialogWithID:dialogId completion:^(NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                    [self.delegate chatManager:self didUpdateStorage:@"Completed"];
                }
                if (completion) {
                    completion(nil);
                }
            }];
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (response.status == QBResponseStatusCodeNotFound || response.status == 403) {
                [self.storage deleteDialogWithID:dialogId completion:^(NSError * _Nullable error) {
                    if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                        [self.delegate chatManager:self didUpdateStorage:@"Completed"];
                    }
                    if (completion) {
                        completion(nil);
                    }
                }];
            }
            NSString *errorMessage = [self errorMessageWithResponse:response];
            if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                [self.delegate chatManager:self didFailUpdateStorage:errorMessage];
            }
            if (completion) {
                completion(errorMessage);
            }
        }];
    } else if (dialog.type == QBChatDialogTypeGroup) {
        [self sendLeave:dialog completionBlock:^(NSError * _Nullable error) {
            dialog.pullOccupantsIDs = @[@(currentUser.ID)];
            [QBRequest updateDialog:dialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull tDialog) {
                [self.storage deleteDialogWithID:dialogId completion:^(NSError * _Nullable error) {
                    if (completion) {
                        completion(nil);
                    }
                }];
            } errorBlock:^(QBResponse * _Nonnull response) {
                if (response.status == QBResponseStatusCodeNotFound || response.status == 403) {
                    [self.storage deleteDialogWithID:dialogId completion:^(NSError * _Nullable error) {
                        if (completion) {
                            completion(nil);
                        }
                    }];
                }
                NSString *errorMessage = [self errorMessageWithResponse:response];
                if ([self.delegate respondsToSelector:@selector(chatManager:didFailUpdateStorage:)]) {
                    [self.delegate chatManager:self didFailUpdateStorage:errorMessage];
                }
                if (completion) {
                    completion(errorMessage);
                }
            }];
        }];
    }
}

- (void)loadDialogWithID:(NSString *)dialogId completion:(void(^)(QBChatDialog *loadedDialog))completion {
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:1 skip:0];
    NSDictionary *extendedRequest = @{@"_id": dialogId};
    
    [QBRequest dialogsForPage:responsePage extendedRequest:extendedRequest successBlock:^(QBResponse * _Nonnull response, NSArray<QBChatDialog *> * _Nonnull dialogs, NSSet<NSNumber *> * _Nonnull dialogsUsersIDs, QBResponsePage * _Nonnull page) {
        if (dialogs.count == 0) {
            if (completion) {
                completion(nil);
            }
            return;
        }
        NSSet *existingUsersIDs = [self.storage fetchAllUsersIDs];
        NSMutableSet *dialogUsersIDs = dialogsUsersIDs.mutableCopy;
        if (existingUsersIDs.count) {
            [dialogUsersIDs minusSet:existingUsersIDs];
        }
        if (dialogUsersIDs.count) {
            NSArray *usersIDs = [dialogUsersIDs allObjects];
            [self loadUsersWithUsersIDs:usersIDs completion:^(QBResponse *response) {}];
        }
        
        QBChatDialog *chatDialog = dialogs.firstObject;
        
        [self.storage updateDialogs:@[chatDialog] completion:^(NSError * _Nullable error) {
            if (completion) {
                completion(chatDialog);
            }
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(nil);
        }
        Log(@"%@ loadDialog error: %@",NSStringFromClass([ChatManager class]),
            [self errorMessageWithResponse:response]);
    }];
}

- (void)loadUserWithID:(NSUInteger)ID completion:(void(^)(QBUUser * _Nullable user))completion {
    [QBRequest userWithID:ID successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        [self.storage updateUsers:@[user]];
        if (completion) {
            completion(user);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        Log(@"%@ loadUser error: %@",NSStringFromClass([ChatManager class]),
            [self errorMessageWithResponse:response]);
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)prepareDialogWith:(NSString *)dialogId withMessage:(QBChatMessage *)message {
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull == NO) {
        return;
    }
    NSInteger currentUserID = profile.ID;
    
    QBChatDialog *dialog = [self.storage dialogWithID:dialogId];
    if (dialog) {
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = message.dateSent;
        dialog.updatedAt = message.dateSent;
        if (message.senderID != currentUserID) {
            dialog.unreadMessagesCount = dialog.unreadMessagesCount + 1;
        }
        if (message.attachments.count) {
            dialog.lastMessageText = @"[Attachment]";
        }
        if (message.isNotificationMessage) {
            if (message.isNotificationMessageTypeAdding) {
                NSArray *occupantIDs = dialog.occupantIDs;
                NSString *strIDs = message.customParameters[@"new_occupants_ids"];
                NSArray *strArrayIDs = [strIDs componentsSeparatedByString:@","];
                NSMutableArray *newOccupantIDs = [NSMutableArray array];
                NSMutableArray *missingOccupantIDs = [NSMutableArray array];
                for (NSString *strID in strArrayIDs) {
                    if ([occupantIDs containsObject: @(strID.integerValue)]) {
                        continue;
                    }
                    [newOccupantIDs addObject:@(strID.integerValue)];
                    if (![self.storage userWithID:strID.integerValue]) {
                        [missingOccupantIDs addObject:@(strID.integerValue)];
                    }
                }
                if (missingOccupantIDs.count) {
                    NSMutableArray *newUsers = [NSMutableArray array];
                    for (NSNumber *ID in missingOccupantIDs) {
                        [newUsers addObject:ID.stringValue];
                    }
                    [QBRequest usersWithIDs:newUsers
                                       page:nil
                               successBlock:^(QBResponse * _Nonnull response,
                                              QBGeneralResponsePage * _Nonnull page,
                                              NSArray<QBUUser *> * _Nonnull users) {
                        [self.storage updateUsers:users];
                        
                        dialog.occupantIDs = [occupantIDs arrayByAddingObjectsFromArray:newOccupantIDs];
                        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                                [self.delegate chatManager:self didUpdateChatDialog:dialog];
                            }
                        }];
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        Log(@"%@ prepareDialog error: %@",NSStringFromClass([ChatManager class]),
                            [self errorMessageWithResponse:response]);
                    }];
                    
                } else {
                    dialog.occupantIDs = [occupantIDs arrayByAddingObjectsFromArray:newOccupantIDs];
                    [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                        if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                            [self.delegate chatManager:self didUpdateChatDialog:dialog];
                        }
                    }];
                }
            } else if (message.isNotificationMessageTypeLeave) {
                if ([dialog.occupantIDs containsObject: @(message.senderID)]) {
                    NSMutableArray *occupantIDs = [NSMutableArray arrayWithArray: dialog.occupantIDs];
                    
                    [occupantIDs removeObject:@(message.senderID)];
                    
                    dialog.occupantIDs = [occupantIDs copy];
                    [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                        if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                            [self.delegate chatManager:self didUpdateChatDialog:dialog];
                        }
                    }];
                }
            }
        } else {
            [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                    [self.delegate chatManager:self didUpdateChatDialog:dialog];
                }
            }];
        }
    } else {
        [self loadDialogWithID:dialogId completion:^(QBChatDialog * _Nonnull loadedDialog) {
            if (!loadedDialog) {
                return;
            }
            if (message.isNotificationMessageTypeCreate) {
                if (loadedDialog.type == QBChatDialogTypePrivate) {
                    return;
                }
                loadedDialog.unreadMessagesCount = 1;
            }
            NSString *lastMessageText = loadedDialog.lastMessageText ? : message.text;
            loadedDialog.lastMessageText = lastMessageText;
            if (message.attachments.count) {
                loadedDialog.lastMessageText = @"[Attachment]";
            }
            loadedDialog.updatedAt = [NSDate date];
            [self.storage updateDialogs:@[loadedDialog] completion:^(NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                    [self.delegate chatManager:self didUpdateChatDialog:loadedDialog];
                }
            }];
        }];
    }
}

- (void)updateDialogWith:(NSString *)dialogId withMessage:(QBChatMessage *)message {
    QBUUser *userSender = [self.storage userWithID: message.senderID];
    if (!userSender) {
        [QBRequest userWithID:message.senderID successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
            [self.storage updateUsers:@[user]];
            [self prepareDialogWith:dialogId withMessage:message];
        } errorBlock:^(QBResponse * _Nonnull response) {
            Log(@"%@ updateDialog error: %@",NSStringFromClass([ChatManager class]),
                [self errorMessageWithResponse:response]);
        }];
    } else {
        [self prepareDialogWith:dialogId withMessage:message];
    }
}

//MARK: - Messages
- (void)messagesWithDialogID:(NSString *)dialogId
             extendedRequest:(nullable NSDictionary *)extendedParameters
                        skip:(NSInteger)skip
                       limit:(NSUInteger)limit
                     success:(nullable MessagesCompletion)success
                errorHandler:(nullable MessagesErrorHandler)errorHandler {
    QBResponsePage *responsePage = [QBResponsePage responsePageWithLimit:limit skip:skip];
    NSDictionary *extendedRequest = extendedParameters.count > 0 ? extendedParameters : [self parametersForMessages];
    [QBRequest messagesWithDialogID:dialogId
                    extendedRequest:extendedRequest
                            forPage:responsePage
                       successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page)
     {
        NSArray *sortedMessages = [[messages reverseObjectEnumerator] allObjects];
        Boolean cancel = NO;
        NSInteger numberOfMessages = sortedMessages.count;
        cancel = numberOfMessages < page.limit ? YES : NO;
        if (success) {
            success(sortedMessages, cancel);
        }
    } errorBlock:^(QBResponse *response) {
        if (errorHandler) {
            errorHandler([self errorMessageWithResponse:response]);
        }
    }];
}

- (void)sendMessage:(QBChatMessage *)message
           toDialog:(QBChatDialog *)dialog
         completion:(QBChatCompletionBlock)completion {
    [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
        if (error) {
            if (completion) {
                completion(error);
            }
        } else {
            dialog.updatedAt = [NSDate date];
            [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                    [self.delegate chatManager:self didUpdateChatDialog:dialog];
                }
                if (completion) {
                    completion(nil);
                }
            }];
        }
    }];
}

- (void)readMessage:(QBChatMessage *)message
             dialog:(QBChatDialog *)dialog
         completion:(QBChatCompletionBlock)completion {
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull == NO) {
        return;
    }
    NSInteger currentUserID = profile.ID;
    if ([self.delegate respondsToSelector:@selector(chatManagerWillUpdateStorage:)]) {
        [self.delegate chatManagerWillUpdateStorage:self];
    }
    if   (![message.dialogID isEqualToString: dialog.ID])  {
        return;
    }
    if (![message.deliveredIDs containsObject:@(currentUserID)]) {
        [QBChat.instance markAsDelivered:message completion:^(NSError * _Nullable error) {}];
    }
    [QBChat.instance readMessage:message completion:^(NSError * _Nullable error) {
        
        if (error != nil) {
            if (completion) {
                completion(error);
            }
            return;
        }
        
        // updating dialog
        if (dialog.unreadMessagesCount > 0) {
            dialog.unreadMessagesCount = dialog.unreadMessagesCount - 1;
        }
        
        if (UIApplication.sharedApplication.applicationIconBadgeNumber > 0) {
            UIApplication.sharedApplication.applicationIconBadgeNumber = UIApplication.sharedApplication.applicationIconBadgeNumber - 1;
        }
        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:dialog];
            }
            if (completion) {
                completion(nil);
            }
        }];
    }];
}

- (void)readMessages:(NSArray<QBChatMessage*> *)messages
              dialog:(QBChatDialog *)dialog
          completion:(QBChatCompletionBlock)completion {
    Profile *profile = [[Profile alloc] init];
    if (profile.isFull == NO) {
        return;
    }
    NSInteger currentUserID = profile.ID;
    dispatch_group_t readGroup = dispatch_group_create();
    
    for (QBChatMessage *message in messages) {
        if   (![message.dialogID isEqualToString: dialog.ID])  {
            continue;
        }
        dispatch_group_enter(readGroup);
        if (![message.deliveredIDs containsObject:@(currentUserID)]) {
            [QBChat.instance markAsDelivered:message completion:^(NSError * _Nullable error) {}];
        }
        [QBChat.instance readMessage:message completion:^(NSError * _Nullable error) {
            dispatch_group_leave(readGroup);
            if (error == nil) {
                // updating dialog
                if (dialog.unreadMessagesCount > 0) {
                    dialog.unreadMessagesCount = dialog.unreadMessagesCount - 1;
                }
                if (UIApplication.sharedApplication.applicationIconBadgeNumber > 0) {
                    UIApplication.sharedApplication.applicationIconBadgeNumber = UIApplication.sharedApplication.applicationIconBadgeNumber - 1;
                }
            } else {
                dispatch_group_leave(readGroup);
                if (completion) {
                    completion(error);
                }
                return;
            }
        }];
    }
    dispatch_group_notify(readGroup, dispatch_get_main_queue(), ^{
        [self.storage updateDialogs:@[dialog] completion:^(NSError * _Nullable error) {
            if ([self.delegate respondsToSelector:@selector(chatManager:didUpdateChatDialog:)]) {
                [self.delegate chatManager:self didUpdateChatDialog:dialog];
            }
            if (completion) {
                completion(nil);
            }
        }];
    });
}

- (void)joinOccupantsWithIDs:(NSArray<NSNumber*> *)ids
                    toDialog:(QBChatDialog *)dialog
                  completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion {
    NSMutableArray * pushOccupantsIDs = [NSMutableArray array];
    for (NSNumber *ID in ids) {
        [pushOccupantsIDs addObject:ID.stringValue];
    }
    dialog.pushOccupantsIDs = [pushOccupantsIDs copy];
    
    [QBRequest updateDialog:dialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nonnull updatedDialog) {
        dialog.pushOccupantsIDs = @[];
        [self sendAdd:ids toDialog:updatedDialog completionBlock:^(NSError * _Nullable error) {
            [self.storage updateDialogs:@[updatedDialog] completion:^(NSError * _Nullable error) {
                if (completion) {
                    completion(response, updatedDialog);
                }
            }];
        }];
    } errorBlock:^(QBResponse * _Nonnull response) {
        dialog.pushOccupantsIDs = @[];
        if (completion) {
            completion(response, nil);
        }
    }];
}

//MARK: - Internal Methods
//MARK: - Users
- (void)searchUsersName:(NSString *)name
            currentPage:(NSUInteger)currentPage
                perPage:(NSUInteger)perPage
             completion:(void(^)(QBResponse *response, NSArray<QBUUser *> *objects, Boolean cancel))completion {
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage];
    [QBRequest usersWithFullName:name page:page successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        BOOL cancel = users.count < page.perPage;
        if (completion) {
            completion(response, users, cancel);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response, @[], NO);
        }
    }];
}

- (void)fetchUsersWithCurrentPage:(NSUInteger)currentPage
                          perPage:(NSUInteger)perPage
                       completion:(void(^)(QBResponse *response, NSArray<QBUUser *> *objects, Boolean cancel))completion {
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage];
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc date last_request_at"} page:page successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        BOOL cancel = users.count < page.perPage;
        if (completion) {
            completion(response, users, cancel);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response, @[], NO);
        }
    }];
}

- (void)updateUsersWithCompletion:(void(^)(QBResponse *response))completion {
    QBGeneralResponsePage *firstPage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
    
    [QBRequest usersWithExtendedRequest:@{@"order": @"desc date last_request_at"} page:firstPage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
        [self.storage updateUsers:users];
        if (completion) {
            completion(response);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        if (completion) {
            completion(response);
        }
    }];
}

- (void)loadUsersWithUsersIDs:(NSArray<NSString *> *)usersIDs
                   completion:(void(^)(QBResponse *response))completion {
    __block NSUInteger skip = 1;
    __block void(^t_request)(QBGeneralResponsePage *usersPage);
    void(^request)(QBGeneralResponsePage *usersPage) = ^(QBGeneralResponsePage *usersPage) {
        
        [QBRequest usersWithIDs:usersIDs page:usersPage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
            
            [self.storage updateUsers:users];
            skip = skip + 1;
            BOOL cancel = users.count < kUsersLimit ? YES : NO;
            if (cancel == NO) {
                t_request([QBGeneralResponsePage responsePageWithCurrentPage:skip perPage:kUsersLimit]);
            } else {
                
                if (completion) {
                    completion(response);
                }
                t_request = nil;
            }
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            if (completion) {
                completion(response);
            }
            t_request = nil;
        }];
        
    };
    t_request = [request copy];
    request([QBGeneralResponsePage responsePageWithCurrentPage:skip perPage:kUsersLimit]);
}

//MARK: - Dialogs
- (void)updateAllDialogsWithPageLimit:(NSInteger)limit
                      extendedRequest:(nullable NSDictionary *)extendedParameters
                           completion:(void(^)(QBResponse *response))completion {
    NSDictionary *extendedRequest = [self parametersForMessages];
    __block  NSMutableSet *usersForUpdate = [NSMutableSet set];
    __block  NSMutableSet *existingUsersIDs = [[self.storage fetchAllUsersIDs] mutableCopy];
    void(^updateHandler)(BOOL cancel, NSArray *dialogs) = ^(BOOL cancel, NSArray *dialogs) {
        [self.storage updateDialogs:dialogs completion:^(NSError * _Nullable error) {
            if (cancel && [self.delegate respondsToSelector:@selector(chatManager:didUpdateStorage:)]) {
                [self.delegate chatManager:self didUpdateStorage:@"Completed"];
            }
        }];
    };
    __block void(^t_request)(QBResponsePage *responsePage);
    void(^request)(QBResponsePage *responsePage) = ^(QBResponsePage *responsePage) {
        
        [QBRequest dialogsForPage:responsePage
                  extendedRequest:extendedRequest
                     successBlock:^(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsersIDs, QBResponsePage *page)
         {
            page.skip += dialogs.count;
            BOOL cancel = page.totalEntries <= page.skip;
            
            usersForUpdate = [[usersForUpdate setByAddingObjectsFromSet:dialogsUsersIDs] mutableCopy];
            if (usersForUpdate.count) {
                [usersForUpdate minusSet:existingUsersIDs];
                existingUsersIDs = [[existingUsersIDs setByAddingObjectsFromSet:usersForUpdate] mutableCopy];
                if (usersForUpdate.count) {
                    NSArray *usersIDs = [usersForUpdate allObjects];
                    [self loadUsersWithUsersIDs:usersIDs completion:^(QBResponse *response) {
                        updateHandler(cancel, dialogs);
                    }];
                } else {
                    updateHandler(cancel, dialogs);
                }
            } else {
                updateHandler(cancel, dialogs);
            }
            
            if (cancel == NO) {
                t_request(page);
            } else {
                if (completion) {
                    completion(nil);
                }
                t_request = nil;
            }
        } errorBlock:^(QBResponse *response) {
            if (completion) {
                completion(response);
            }
            t_request = nil;
        }];
    };
    t_request = [request copy];
    request([QBResponsePage responsePageWithLimit:limit]);
}

//MARK: - Messages
- (NSDictionary *)parametersForMessages {
    NSDictionary *parameters = @{@"sort_desc": @"date_sent", @"mark_as_read": @"0"};
    return parameters;
}

//Handle Error
- (NSString *)errorMessageWithResponse:(QBResponse *)response {
    
    switch (response.status) {
        case 502: return @"Bad Gateway, please try again";
        case -1009:
        case -1020:
        case -1002: return @"Connection network error, please try again";
        case 422: return @"Validation Failed";
        default: {
            NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"("
                                                                                             withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            return errorMessage;
        }
    }
}

#pragma mark - QBChatDelegate
- (void)chatDidConnect {
    [self sendDraftMessages];
}

- (void)chatDidReconnect {
    [self sendDraftMessages];
}

@end
