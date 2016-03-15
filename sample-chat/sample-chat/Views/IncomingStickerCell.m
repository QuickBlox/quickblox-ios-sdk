//
//  IncomingStickerCell.m
//  sample-chat
//
//  Created by Olya Lutsyk on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "IncomingStickerCell.h"

@implementation IncomingStickerCell

- (void)awakeFromNib {
    // Initialization code
}

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 15),
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
