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
//@property (strong, nonatomic) NSArray *items;

@end

@implementation SettingsSectionModel

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items {
    
    SettingsSectionModel *section = [SettingsSectionModel new];
    section.title = title;
    section.items = items;
    
    return section;
}

@end
