//
//  UIViewController+ContextMenu.m
//  sample-chat
//
//  Created by Injoit on 28.09.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "UIViewController+ContextMenu.h"
#import "ChatViewController.h"

@implementation UIViewController (ContextMenu)

- (UIMenu *)chatContextMenuOutgoing:(BOOL)isOutgoing forCell:(ChatAttachmentCell * _Nullable)chatAttachmentCell {
    
    if (![self isKindOfClass:[ChatViewController class]] && ![self conformsToProtocol:@protocol(ChatContextMenuProtocol)]) {
        return nil;
    }
    
    ChatViewController *chatViewController = (ChatViewController *)self;
    
    if (chatAttachmentCell) {
        UIAction *saveAttachmentAction = [UIAction actionWithTitle:@"Save Attachment" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [chatViewController saveFileAttachmentFromChatAttachmentCell:chatAttachmentCell];
        }];
        return  [UIMenu menuWithTitle:@"" children: @[saveAttachmentAction]];;
    }
    
    UIAction *forwardAction = [UIAction actionWithTitle:@"Forward" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [chatViewController forwardAction];
    }];
    
    UIAction *deliveredToAction = [UIAction actionWithTitle:@"Delivered to..." image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [chatViewController deliveredToAction];
    }];
    
    UIAction *viewedByAction = [UIAction actionWithTitle:@"Viewed by..." image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [chatViewController viewedByAction];
    }];
    
    NSArray *children = isOutgoing == true ? @[forwardAction, deliveredToAction, viewedByAction] : @[forwardAction];
    
    UIMenu *menu = [UIMenu menuWithTitle:@"" children: children];
    
    return menu;
}

@end
