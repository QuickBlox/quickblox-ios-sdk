//
//  ChatAttachmentIncomingCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatAttachmentIncomingCell.h"
#import "UIView+Chat.h"

@interface ChatAttachmentIncomingCell()

@end

@implementation ChatAttachmentIncomingCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.previewContainer  roundCornersWithRadius:6.0f isIncoming:YES];
}

+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(40, 40);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    
    return defaultLayoutModel;
}

@end
