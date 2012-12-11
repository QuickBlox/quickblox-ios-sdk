//
//  UserTableViewCell.m
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/19/12.
//  Copyright (c) 2012 Ruslan. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

@synthesize text;
@synthesize icon;
@synthesize status;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        icon = [[UIImageView alloc] init];
        [self.icon setFrame:CGRectMake(20, 4, 35, 35)];
        [self addSubview:self.icon];
        [icon release];
        
        text = [[UILabel alloc] init];
        [self.text setFrame:CGRectMake(65, 6, 280, 30)];
        [self.text setFont:[UIFont fontWithName:@"TrebuchetMS" size:14]];
        [self addSubview:self.text];
        [text release];
        
        status = [[UIImageView alloc] init];
        [self.status setFrame:CGRectMake(285, 18, 9, 9)];
        [self addSubview:self.status];
        [status release];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

@end