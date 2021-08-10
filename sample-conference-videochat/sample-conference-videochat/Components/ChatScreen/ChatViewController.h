//
//  ChatViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatManager.h"

NS_ASSUME_NONNULL_BEGIN

@class ChatViewController;
//@class CallSettings;

typedef void(^CloseChatScreen)(void);
typedef void(^OpenCallScreen)(ConferenceSettings * _Nullable settings);

@class ChatAttachmentCell;

@interface ChatViewController : UIViewController
@property (strong, nonatomic) QBChatDialog *dialog;
@property (strong, nonatomic) CloseChatScreen didCloseChatVC;
@property (strong, nonatomic) OpenCallScreen didOpenCallScreenWithSettings;
@property (nonatomic, assign) ChatAction action;

// metods ChatContextMenuProtocol
//- (void)forwardAction;
//- (void)deliveredToAction;
//- (void)viewedByAction;
- (void)saveFileAttachmentFromChatAttachmentCell:(ChatAttachmentCell *)chatAttachmentCell;
- (void)sendAddOccupantsMessages:(NSArray<NSNumber *> *)selectedUsers action:(DialogActionType)action;
@end

NS_ASSUME_NONNULL_END
