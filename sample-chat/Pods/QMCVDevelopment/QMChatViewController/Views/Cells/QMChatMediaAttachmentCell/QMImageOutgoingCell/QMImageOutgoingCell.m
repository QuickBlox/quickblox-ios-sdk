//
//  QMImageOutgoingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/27/17.
//
//

#import "QMImageOutgoingCell.h"

@implementation QMImageOutgoingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.mediaPlayButton.hidden = YES;
}

@end
