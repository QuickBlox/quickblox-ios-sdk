//
//  SwitchItemModel.m
//  sample-conference-videochat
//
//  Created by Injoit on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SwitchItemModel.h"
#import "SettingSwitchCell.h"

@implementation SwitchItemModel

- (Class)viewClass {
    
    return [SettingSwitchCell class];
}

@end
