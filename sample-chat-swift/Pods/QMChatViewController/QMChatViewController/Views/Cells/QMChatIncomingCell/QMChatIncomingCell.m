//
//  QMChatIncomingCell.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 29.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatIncomingCell.h"

@implementation QMChatIncomingCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.containerView.bgColor = [UIColor whiteColor];
}

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 15, 4, 4);
    
    return defaultLayoutModel;
}

@end
