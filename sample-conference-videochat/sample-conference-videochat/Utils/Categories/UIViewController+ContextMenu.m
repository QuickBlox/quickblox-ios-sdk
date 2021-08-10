//
//  UIViewController+ContextMenu.m
//  sample-conference-videochat
//
//  Created by Injoit on 28.09.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UIViewController+ContextMenu.h"
#import "ChatViewController.h"

@implementation UIViewController (ContextMenu)

- (UIMenu *)chatContextMenuForCell:(ChatAttachmentCell * _Nullable)chatAttachmentCell {
    
    if (![self isKindOfClass:[ChatViewController class]] && ![self conformsToProtocol:@protocol(ChatContextMenuProtocol)]) {
        return nil;
    }
    
    ChatViewController *chatViewController = (ChatViewController *)self;

        UIAction *saveAttachmentAction = [UIAction actionWithTitle:@"Save Attachment" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [chatViewController saveFileAttachmentFromChatAttachmentCell:chatAttachmentCell];
        }];
        return  [UIMenu menuWithTitle:@"" children: @[saveAttachmentAction]];;
}

@end
