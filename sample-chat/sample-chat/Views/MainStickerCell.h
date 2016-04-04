//
//  MainStickerCell.h
//  sample-chat
//
//  Created by Olya Lutsyk on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatCell.h"

@interface MainStickerCell : QMChatCell

@property (nonatomic, weak) IBOutlet UIImageView *stickerImage;

+ (QMChatCellLayoutModel)layoutModel;

@end
