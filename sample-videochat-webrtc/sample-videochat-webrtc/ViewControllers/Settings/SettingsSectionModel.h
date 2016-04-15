//
//  SettingsSectionModel.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSettingsController.h"

@interface SettingsSectionModel : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (assign, nonatomic) SettingsSectionType type;
@property (strong, nonatomic) NSArray *items;

/// Init is not a supported initializer for this class
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items type:(SettingsSectionType)type;

@end
