//
//  UIViewController+ContextMenu.h
//  samplechat
//
//  Created by Injoit on 28.09.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChatAttachmentCell;

@protocol ChatContextMenuProtocol <NSObject>
@required
- (void)forwardAction;
- (void)deliveredToAction;
- (void)viewedByAction;
- (void)saveFileAttachmentFromChatAttachmentCell:(ChatAttachmentCell *)chatAttachmentCell;
@end

@interface UIViewController (ContextMenu)

- (UIMenu *)chatContextMenuOutgoing:(BOOL)isOutgoing forCell:(ChatAttachmentCell * _Nullable)chatAttachmentCell;

@end

NS_ASSUME_NONNULL_END
