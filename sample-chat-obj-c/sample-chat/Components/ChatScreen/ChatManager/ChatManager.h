//
//  ChatManager.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatStorage.h"
#import <Quickblox/Quickblox.h>
#import "Profile.h"
#import "Log.h"

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
};

NS_ASSUME_NONNULL_BEGIN

extern NSString *const UpdatedChatDialogNotification;
extern NSString *const UpdatedChatDialogNotificationKey;

@class ChatManager;

typedef void(^DialogCompletion)(NSError * _Nullable error,  QBChatDialog * _Nullable dialog);
typedef void(^MessagesCompletion)(NSArray<QBChatMessage *> *messages, Boolean isLast);
typedef void(^MessagesErrorHandler)(NSString * _Nullable error);
typedef void(^SendMessageCompletion)(NSError * _Nullable error, QBChatMessage *message);

@protocol ChatManagerDelegate <NSObject>
@optional
- (void)chatManager:(ChatManager *)chatManager didFailUpdateStorage:(NSString *)message;
- (void)chatManager:(ChatManager *)chatManager didUpdateStorage:(NSString *)message;
- (void)chatManager:(ChatManager *)chatManager didUpdateChatDialog:(QBChatDialog*)chatDialog;

@end

@interface ChatManager : NSObject

@property (nonatomic, weak) id <ChatManagerDelegate> delegate;
@property (strong, nonatomic) ChatStorage *storage;
@property (strong, nonatomic) NSMutableSet<QBChatMessage *> *draftMessages;

+ (instancetype)instance;

- (void)updateStorage;
- (void)createGroupDialogWithName:(NSString *)name
                        occupants:(NSArray<QBUUser *> *)occupants
                       completion:(nullable DialogCompletion)completion;
- (void)createPrivateDialogWithOpponent:(QBUUser *)opponent
                             completion:(nullable DialogCompletion)completion;
- (void)leaveDialogWithID:(NSString *)dialogId completion:(nullable MessagesErrorHandler)completion;
- (void)loadDialogWithID:(NSString *)dialogId completion:(void(^)(QBChatDialog *loadedDialog))completion;
- (void)updateDialogWith:(NSString *)dialogId withMessage:(QBChatMessage *)message;
- (void)messagesWithDialogID:(NSString *)dialogId
             extendedRequest:(nullable NSDictionary *)extendedParameters
                        skip:(NSInteger)skip
                       limit:(NSUInteger)limit
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

@end

NS_ASSUME_NONNULL_END
