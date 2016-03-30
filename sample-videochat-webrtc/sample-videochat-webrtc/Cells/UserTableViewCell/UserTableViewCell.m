//
//  UserTableViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "UserTableViewCell.h"
#import "CornerView.h"

@implementation UserTableViewCell

- (void)setMarkerColor:(UIColor *)color {
    
    self.colorMarker.bgColor = color;
}

- (void)setMarkerText:(NSString *)text {
	self.colorMarker.title = [text uppercaseString];
}

- (void)setUserDescription:(NSString *)userDescription {
    
    if (![_userDescription isEqualToString:userDescription]) {

        _userDescription = userDescription;
        self.userDescriptionLabel.text = userDescription;
    }
}

@end
