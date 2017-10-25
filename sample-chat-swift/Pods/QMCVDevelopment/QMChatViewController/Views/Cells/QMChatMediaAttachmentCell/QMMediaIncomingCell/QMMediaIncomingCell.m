//
//  QMMediaIncomingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/10/17.
//
//

#import "QMMediaIncomingCell.h"

@implementation QMMediaIncomingCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.circularProgress.tintColor = [UIColor colorWithRed:127/255.0 green:140/255.0 blue:155/255.0 alpha:1.0];
    self.mediaPlayButton.tintColor = [UIColor colorWithRed:127/255.0 green:140/255.0 blue:155/255.0 alpha:1.0];
    self.durationLabel.textColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
}


+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 12, 4, 4),
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    return defaultLayoutModel;
}

@end
