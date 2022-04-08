//
//  ChatViewController.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatManager.h"

NS_ASSUME_NONNULL_BEGIN

@class ChatAttachmentCell;

@interface ChatViewController : UIViewController
@property (strong, nonatomic) NSString *dialogID;

// metods ChatContextMenuProtocol
- (void)forwardAction;
- (void)deliveredToAction;
- (void)viewedByAction;
- (void)saveFileAttachmentFromChatAttachmentCell:(ChatAttachmentCell *)chatAttachmentCell;
@end

NS_ASSUME_NONNULL_END
