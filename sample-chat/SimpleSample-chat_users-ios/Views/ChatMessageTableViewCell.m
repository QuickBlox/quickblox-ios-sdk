//
//  ChatMessageTableViewCell.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/21/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ChatMessageTableViewCell.h"

@implementation ChatMessageTableViewCell

@synthesize message;
@synthesize date;
@synthesize backgroundImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        date = [[[UILabel alloc] init] autorelease];
        [self.date setFrame:CGRectMake(10, 5, 300, 20)];
        [self.date setFont:[UIFont systemFontOfSize:11.0]];
        [self.date setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.date];
        
        backgroundImageView = [[[UIImageView alloc] init] autorelease];
        [self.backgroundImageView setFrame:CGRectZero];
		[self.contentView addSubview:self.backgroundImageView];
        
		message = [[[UITextView alloc] init] autorelease];
        [self.message setBackgroundColor:[UIColor clearColor]];
        [self.message setEditable:NO];
        [self.message setScrollEnabled:NO];
		[self.message sizeToFit];
		[self.contentView addSubview:self.message];
    }
    return self;
}

@end
