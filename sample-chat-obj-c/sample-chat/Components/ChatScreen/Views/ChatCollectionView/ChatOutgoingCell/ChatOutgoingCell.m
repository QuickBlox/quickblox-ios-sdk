//
//  ChatOutgoingCell.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatOutgoingCell.h"

@implementation ChatOutgoingCell
+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(8, 10, 8, 18);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.spaceBetweenTextViewAndBottomLabel = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
