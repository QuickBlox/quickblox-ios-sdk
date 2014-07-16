//
//  CustomTableViewCell.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

@synthesize noteLabel;
@synthesize dataLabel;
@synthesize statusLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *backgroundImageView = [[UIImageView alloc] init];
        [backgroundImageView setFrame:CGRectMake(0, 0, 320, 80)];
        [backgroundImageView setImage:[UIImage imageNamed:@"Background"]];
        [backgroundImageView setAlpha:0.7];
        [self addSubview:backgroundImageView];

        UILabel *note = [[UILabel alloc] init];
        [note setFrame:CGRectMake(10, 10, 60, 20)];
        [note setText:@"Note: "];
        [note setBackgroundColor:[UIColor clearColor]];
        [note setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:17]];
        [self addSubview:note];
        
        noteLabel = [[UILabel alloc] init];
        [self.noteLabel setFrame:CGRectMake(70, 10, 260, 20)];
        [self.noteLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.noteLabel];
        
        UILabel *status = [[UILabel alloc] init];
        [status setFrame:CGRectMake(10, 30, 60, 20)];
        [status setText:@"Status: "];
        [status setBackgroundColor:[UIColor clearColor]];
        [status setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:17]];
        [self addSubview:status];
        
        statusLabel = [[UILabel alloc] init];
        [self.statusLabel setFrame:CGRectMake(70, 30, 260, 20)];
        [self.statusLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.statusLabel];
        
        UILabel *date = [[UILabel alloc] init];
        [date setFrame:CGRectMake(10, 50, 60, 20)];
        [date setText:@"Data: "];
        [date setBackgroundColor:[UIColor clearColor]];
        [date setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:17]];
        [self addSubview:date];
        
        dataLabel = [[UILabel alloc] init];
        [self.dataLabel setFrame:CGRectMake(70, 50, 260, 20)];
        [self.dataLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.dataLabel];
        
        self.selectionStyle = 0;
    }
    return self;
}


@end
