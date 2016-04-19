//
//  SettingSwichCell.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SettingSwichCell.h"
#import "SwitchItemModel.h"

@interface SettingSwichCell()

@property (weak, nonatomic) IBOutlet UISwitch *switchCtrl;

@end

@implementation SettingSwichCell

- (void)setModel:(SwitchItemModel *)model {
    
    [super setModel:model];
    self.switchCtrl.on = model.on;
}

- (IBAction)valueChanged:(UISwitch *)sender {
    
    SwitchItemModel *model = (id)self.model;
    model.on = sender.on;
    [self.delegate cell:self didChageModel:self.model];
}

@end
