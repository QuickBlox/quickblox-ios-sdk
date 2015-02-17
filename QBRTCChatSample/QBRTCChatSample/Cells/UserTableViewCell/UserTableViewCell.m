//
//  UserTableViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "UserTableViewCell.h"
#import "CornerView.h"

@interface UserTableViewCell()

@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UILabel *userDescriptionLabel;

@end

@implementation UserTableViewCell

- (void)setColorMarkerText:(NSString *)text andColor:(UIColor *)color {
    
    self.colorMarker.bgColor = color;
    self.colorMarker.title = text;
}

- (void)setUserDescription:(NSString *)userDescription {
    
    if (![_userDescription isEqualToString:userDescription]) {

        _userDescription = userDescription;
        self.userDescriptionLabel.text = userDescription;
    }
}

@end
