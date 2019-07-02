//
//  BaseSettingsCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "BaseSettingsCell.h"

@implementation BaseSettingsCell

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

- (void)setModel:(BaseItemModel *)model {
    
    _model = model;
    self.label.text = model.title;
}

@end
