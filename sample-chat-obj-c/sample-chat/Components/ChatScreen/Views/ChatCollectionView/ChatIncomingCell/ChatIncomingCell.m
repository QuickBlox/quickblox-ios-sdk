//
//  ChatIncomingCell.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatIncomingCell.h"

@implementation ChatIncomingCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(8, 18, 8, 10);
    
    return defaultLayoutModel;
}
@end
