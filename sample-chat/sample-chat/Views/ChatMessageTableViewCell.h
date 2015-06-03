//
//  ChatMessageTableViewCell.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/19/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UITextView  *messageTextView;
@property (nonatomic, strong) UILabel     *nameAndDateLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;

+ (CGFloat)heightForCellWithMessage:(QBChatMessage *)message;
- (void)configureCellWithMessage:(QBChatMessage *)message;

@end
