//
//  QMChatLocationIncomingCell.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatLocationIncomingCell.h"

@implementation QMChatLocationIncomingCell

#pragma mark - Default layout

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 15),
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
