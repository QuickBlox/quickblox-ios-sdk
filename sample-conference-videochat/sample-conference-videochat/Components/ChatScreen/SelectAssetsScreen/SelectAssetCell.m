//
//  SelectAssetCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SelectAssetCell.h"
#import "UIView+Chat.h"

@implementation SelectAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkBoxImageView.hidden = YES;
    self.checkBoxView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.35f];
    [self.checkBoxView setRoundBorderEdgeColorView:4.0f borderWidth:1.0f color:nil borderColor:UIColor.whiteColor];
    [self.videoTypeView setRoundViewWithCornerRadius:3.0f];
    self.videoTypeView.hidden = YES;
    self.assetImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.assetTypeImageView.image = nil;
    self.checkBoxView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.35f];
    [self.checkBoxView setRoundBorderEdgeColorView:4.0f borderWidth:1.0f color:nil borderColor:UIColor.whiteColor];
    self.videoTypeView.hidden = YES;
    self.checkBoxImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected {
    [self onSelectedCell:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self onSelectedCell:highlighted];
}

- (void)onSelectedCell:(Boolean)newValue {
    if (newValue == YES) {
        self.checkBoxImageView.hidden = NO;
        self.contentView.backgroundColor = [UIColor colorWithRed:0.85f green:0.89f blue:0.97f alpha:1.0f];
        [self.checkBoxView setRoundBorderEdgeColorView:4.0f
                                           borderWidth:1.0f
                                                 color:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]
                                           borderColor:[UIColor colorWithRed:0.22f green:0.47f blue:0.99f alpha:1.0f]];
    } else {
        self.checkBoxImageView.hidden = YES;
        self.contentView.backgroundColor = UIColor.clearColor;
        [self.checkBoxView setRoundBorderEdgeColorView:4.0f
        borderWidth:1.0f
              color:[UIColor.whiteColor colorWithAlphaComponent:0.35f]
        borderColor:UIColor.whiteColor];
    }
}

@end
