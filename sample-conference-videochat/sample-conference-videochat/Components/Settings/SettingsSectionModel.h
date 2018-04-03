//
//  SettingsSectionModel.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsSectionModel : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic) NSArray *items;

/// Init is not a supported initializer for this class
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items;

@end
