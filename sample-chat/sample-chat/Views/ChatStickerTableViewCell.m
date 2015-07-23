//
//  ChatStickerTableViewCell.m
//  sample-chat
//
//  Created by Vadim Degterev on 16.07.15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "ChatStickerTableViewCell.h"
#import <STKStickerPipe.h>

@implementation ChatStickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.stickerImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.stickerImage];
        
        self.nameAndDateLabel = [[UILabel alloc] init];
        [self.nameAndDateLabel setFrame:CGRectMake(10, 5, 300, 20)];
        [self.nameAndDateLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.nameAndDateLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.nameAndDateLabel];
    }
    return self;
}



- (void) fillWithStickerMessage:(QBChatMessage*)message {
    
    CGSize imageSize = CGSizeMake(80.0, 80.0);
    
    NSString *time = [message.dateSent timeAgoSinceNow];
    
        if ([QBSession currentSession].currentUser.ID == message.senderID) {
            [self.stickerImage setFrame:CGRectMake(10.0, 25.0, 80.0, 80.0)];
            self.nameAndDateLabel.textAlignment = NSTextAlignmentLeft;
            self.nameAndDateLabel.text = [NSString stringWithFormat:@"Me, %@", time];
        } else {
            [self.stickerImage setFrame:CGRectMake(self.frame.size.width - imageSize.width - 20.0, 25.0, 80.0, 80.0)];
            
            self.nameAndDateLabel.textAlignment = NSTextAlignmentRight;
            
            QBUUser *sender = [ChatService shared].usersAsDictionary[@(message.senderID)];
            self.nameAndDateLabel.text = [NSString stringWithFormat:@"%@, %@", sender.login == nil ? (sender.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)sender.ID] : sender.fullName) : sender.login, time];
        }
    
    [self.stickerImage stk_setStickerWithMessage:message.text completion:nil];
}

@end
