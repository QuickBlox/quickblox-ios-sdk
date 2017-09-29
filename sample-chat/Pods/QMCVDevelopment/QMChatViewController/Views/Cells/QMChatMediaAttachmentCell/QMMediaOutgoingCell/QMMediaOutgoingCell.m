//
//  QMMediaOutgoingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/10/17.
//
//

#import "QMMediaOutgoingCell.h"

@implementation QMMediaOutgoingCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 12),
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.mediaPlayButton.tintColor = [UIColor whiteColor];
    self.circularProgress.tintColor = [UIColor whiteColor];
    self.durationLabel.textColor = [UIColor whiteColor];
}

@end
