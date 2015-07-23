//
//  ChatStickerTableViewCell.h
//  sample-chat
//
//  Created by Vadim Degterev on 16.07.15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatStickerTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *stickerImage;
@property (nonatomic, strong) UILabel     *nameAndDateLabel;


- (void) fillWithStickerMessage:(QBChatMessage*)message;

@end
