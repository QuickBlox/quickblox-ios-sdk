//
//  STKStickerSettingsCell.h
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKStickerPackObject;

@interface STKStickerSettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *packTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *packDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *packIconImageView;

- (void)configureWithStickerPack:(STKStickerPackObject*)stickerPack;

@end
