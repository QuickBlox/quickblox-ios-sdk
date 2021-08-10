//
//  BaseSettingsCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
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
