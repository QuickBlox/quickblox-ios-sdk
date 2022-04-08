//
//  ChatManager+InfoMessages.h
//  sample-chat
//
//  Created by Injoit on 11.01.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "ChatManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager (InfoMessages)
/// Sending an info message to dialog about leaving.
/// @param dialog The dialog to which the info to be sent.
/// @param completion The closure to execute when the send operation is complete.
/// error: On success, the value of this parameter is nil. If an error occurred, this parameter contains the error object indicating what happened.
- (void)sendLeave:(QBChatDialog *)dialog completionBlock:(QBChatCompletionBlock)completion;

/// Sending an info message to the dialog about creation and sending system messages to participants.
/// @param dialog The dialog to which the info to be sent.
/// @param completion The closure to execute when the send operation is complete.
/// error: On success, the value of this parameter is nil. If an error occurred, this parameter contains the error object indicating what happened.
- (void)sendCreateToDialog:(QBChatDialog *)dialog
   completionBlock:(QBChatCompletionBlock)completion;

/// Sending an info message to the dialog about added new members and sending system messages to new members.
/// @param usersIDs The new participants IDs.
/// @param dialog The dialog to which the info to be sent.
- (void)sendAdd:(NSArray<NSNumber *> *)usersIDs
       toDialog:(QBChatDialog *)dialog completionBlock:(QBChatCompletionBlock)completion;

/// Resent the unsent info messages.
- (void)sendDraftMessages;
@end

NS_ASSUME_NONNULL_END
