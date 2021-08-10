//
//  ChatAttachmentOutgoingCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatAttachmentOutgoingCell.h"
#import "UIView+Chat.h"

@implementation ChatAttachmentOutgoingCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.previewContainer  roundCornersWithRadius:6.0f isIncoming:NO];
}

@end
