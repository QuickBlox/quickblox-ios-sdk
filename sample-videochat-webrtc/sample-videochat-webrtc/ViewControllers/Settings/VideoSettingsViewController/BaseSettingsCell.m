//
//  BaseSettingsCell.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "BaseSettingsCell.h"

@implementation BaseSettingsCell

- (void)setModel:(BaseItemModel *)model {
    
    _model = model;
    self.label.text = model.title;
}

@end
