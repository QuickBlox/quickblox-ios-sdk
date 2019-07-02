//
//  SettingsSectionModel.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
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
