//
//  SettingSwitchCell.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SettingSwitchCell.h"
#import "SwitchItemModel.h"

@interface SettingSwitchCell()

@property (weak, nonatomic) IBOutlet UISwitch *switchCtrl;

@end

@implementation SettingSwitchCell

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
