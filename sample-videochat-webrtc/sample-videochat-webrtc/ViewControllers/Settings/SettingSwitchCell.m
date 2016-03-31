//
//  SettingSwitchCell.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SettingSwitchCell.h"
#import "SwitchItemModel.h"

@interface SettingSwitchCell ()

@property (weak, nonatomic) IBOutlet UISwitch *switchCtrl;

@end

@implementation SettingSwitchCell

- (void)setModel:(SwitchItemModel *)model {
    
    [super setModel:model];
    self.switchCtrl.on = model.on;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)valueChanged:(UISwitch *)sender {
    
    SwitchItemModel *model = (id)self.model;
    model.on = sender.on;
    if (model.changedBlock) {
        model.changedBlock(model.on);
    }
    if ([self.delegate conformsToProtocol:@protocol(SettingsCellDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(cell:didChangeModel:)]) {
            [self.delegate cell:self didChangeModel:self.model];
        }
    }
}

@end
