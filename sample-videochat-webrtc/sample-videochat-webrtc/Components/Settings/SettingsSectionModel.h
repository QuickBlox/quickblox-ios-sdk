//
//  SettingsSectionModel.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsSectionModel : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic) NSArray *items;

/// Init is not a supported initializer for this class
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items;

@end
