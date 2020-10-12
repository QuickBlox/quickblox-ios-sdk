//
//  ChatViewController.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChatAttachmentCell;

typedef NS_ENUM(NSUInteger, ChatActions) {
    ChatActionsNone = 0,
    ChatActionsLeaveChat,
    ChatActionsChatInfo,
    ChatActionsEdit,
    ChatActionsDelete,
    ChatActionsForward,
    ChatActionsDeliveredTo,
    ChatActionsViewedBy,
    ChatActionsSaveAttachment,
};

@interface ChatViewController : UIViewController
@property (strong, nonatomic) NSString *dialogID;

// metods ChatContextMenuProtocol
- (void)forwardAction;
- (void)deliveredToAction;
- (void)viewedByAction;
- (void)saveFileAttachmentFromChatAttachmentCell:(ChatAttachmentCell *)chatAttachmentCell;
@end

NS_ASSUME_NONNULL_END
