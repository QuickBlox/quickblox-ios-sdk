//
//  BaseItemModel.m
//  sample-conference-videochat
//
//  Created by Injoit on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "BaseItemModel.h"
#import "SettingCell.h"

@implementation BaseItemModel

- (Class)viewClass {
    
    return [SettingCell class];
}

@end
