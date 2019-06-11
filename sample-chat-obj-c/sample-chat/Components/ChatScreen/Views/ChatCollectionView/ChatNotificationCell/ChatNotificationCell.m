//
//  ChatNotificationCell.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatNotificationCell.h"

@implementation ChatNotificationCell

+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 10, 4, 10);
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 0;
    
    return defaultLayoutModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.notificationLabel.backgroundColor = [UIColor clearColor];
}

@end
