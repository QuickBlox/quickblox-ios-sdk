//
//  SettingsSectionModel.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SettingsSectionModel.h"

@interface SettingsSectionModel()

@property (copy, nonatomic) NSString *title;

@end

@implementation SettingsSectionModel

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items type:(SettingsSectionType)type {
    
    SettingsSectionModel *section = [SettingsSectionModel new];
    section.title = title;
    section.items = items;
    section.type = type;
    
    return section;
}

@end
