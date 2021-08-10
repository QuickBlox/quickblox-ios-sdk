//
//  ChatManager.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatStorage.h"
#import <Quickblox/Quickblox.h>
#import "ConferenceSettings.h"

typedef NS_ENUM(NSUInteger, NotificationMessageType) {
    NotificationMessageTypeCreate = 1,
    NotificationMessageTypeAdding = 2,
    NotificationMessageTypeLeave = 3,
    NotificationMessageTypeStartConference = 4,
    NotificationMessageTypeStartStream = 5
};

typedef NS_ENUM(NSUInteger, DialogActionType) {
    DialogActionTypeCreate = 0,
    DialogActionTypeAdd = 1,
};

typedef NS_ENUM(NSUInteger, ChatAction) {
    ChatActionNone = 0,
    ChatActionLeaveChat,
    ChatActionChatInfo,
    ChatActionEdit,
    ChatActionDelete,
    ChatActionForward,
    ChatActionDeliveredTo,
    ChatActionViewedBy,
    ChatActionSaveAttachment,
    ChatActionChatFromCall,
    ChatActionInfoFromCall,
    ChatActionStartConference,
    ChatActionStartStream,
    ChatActionUserProfile,
    ChatActionLogout,
    ChatActionAppInfo,
    ChatActionAudioConfig,
    ChatActionVideoConfig
};

NS_ASSUME_NONNULL_BEGIN

@class ChatManager;

typedef void(^DialogCompletion)(NSError * _Nullable error,  QBChatDialog * _Nullable dialog);
typedef void(^MessagesCompletion)(NSArray<QBChatMessage *> *messages, Boolean isLast);
typedef void(^MessagesErrorHandler)(NSString * _Nullable error);
typedef void(^SendMessageCompletion)(NSError * _Nullable error, QBChatMessage *message);

@protocol ChatManagerDelegate <NSObject>
@optional
- (void)chatManagerWillUpdateStorage:(ChatManager *)chatManager;
- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message;
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message;
- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog*)chatDialog;

@end

@protocol ChatManagerConnectionDelegate <NSObject>
@optional
- (void)chatManagerStartAuthorization:(ChatManager *)chatManager;
- (void)chatManagerAuthorize:(ChatManager *)chatManager;
- (void)chatManagerAuthorizeFailed:(ChatManager *)chatManager;
- (void)chatManagerStartConnection:(ChatManager *)chatManager;
- (void)chatManagerConnect:(ChatManager *)chatManager;
- (void)chatManagerDisconnect:(ChatManager *)chatManager withLostNetwork:(BOOL)lostNetwork;

@end

@interface ChatManager : NSObject

@property (nonatomic, weak) id <ChatManagerDelegate> delegate;
@property (nonatomic, weak) id <ChatManagerConnectionDelegate> connectionDelegate;
@property (strong, nonatomic) ChatStorage *storage;

+ (instancetype)instance;

- (void)updateStorage;
- (void)sendLeaveMessage:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion;
- (void)sendAddingMessage:(NSString *)text
                   action:(DialogActionType) action
                withUsers:(NSArray<NSNumber *> *)usersIDs
                 toDialog:(QBChatDialog *)dialog
               completion:(SendMessageCompletion)completion;
- (void)createGroupDialogWithName:(NSString *)name
                        occupants:(NSArray<QBUUser *> *)occupants
                       completion:(nullable DialogCompletion)completion;
- (void) leaveDialogWithID:(NSString *)dialogId completion:(nullable MessagesErrorHandler)completion;
- (void)loadDialogWithID:(NSString *)dialogId completion:(void(^)(QBChatDialog *loadedDialog))completion;
- (void)updateDialogWith:(NSString *)dialogId withMessage:(QBChatMessage *)message;
- (void)messagesWithDialogID:(NSString *)dialogId
             extendedRequest:(nullable NSDictionary *)extendedParameters
                        skip:(NSInteger)skip
                     success:(nullable MessagesCompletion)success
                errorHandler:(nullable MessagesErrorHandler)errorHandler;
- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog completion:(QBChatCompletionBlock)completion;
- (void)readMessages:(NSArray<QBChatMessage*> *)messages
              dialog:(QBChatDialog *)dialog
          completion:(QBChatCompletionBlock)completion;
- (void)readMessage:(QBChatMessage *)message
             dialog:(QBChatDialog *)dialog
         completion:(QBChatCompletionBlock)completion;
- (void)searchUsersName:(NSString *)name
            currentPage:(NSUInteger)currentPage
                perPage:(NSUInteger)perPage
             completion:(void(^)(QBResponse *response, NSArray<QBUUser *> *objects, Boolean cancel))completion;
- (void)fetchUsersWithCurrentPage:(NSUInteger)currentPage
                          perPage:(NSUInteger)perPage
                       completion:(void(^)(QBResponse *response, NSArray<QBUUser *> *objects, Boolean cancel))completion;
- (void)loadUserWithID:(NSUInteger)ID completion:(void(^)(QBUUser * _Nullable user))completion;
- (void)loadUsersWithUsersIDs:(NSArray<NSString *> *)usersIDs
                   completion:(void(^)(QBResponse *response))completion;
- (void)joinOccupantsWithIDs:(NSArray<NSNumber*> *)ids toDialog:(QBChatDialog *)dialog
                  completion:(void(^)(QBResponse *response, QBChatDialog *updatedDialog))completion;
- (void)connect:(nullable QBChatCompletionBlock)completion;
- (void)disconnect:(nullable QBChatCompletionBlock)completion;
- (void)sendStartConferenceMessage:(ConferenceInfo *)conferenceInfo completion:(QBChatCompletionBlock)completion;

- (void)activateAutomaticMode;
- (BOOL)onConnect;
- (BOOL)tokenHasExpired;
- (void)breakConnectionWithCompletion:(nonnull void (^)(void))completion;
- (void)deactivateAutomaticMode;
- (BOOL)isNetworkLost;
- (void)establishConnection;

@end

NS_ASSUME_NONNULL_END
