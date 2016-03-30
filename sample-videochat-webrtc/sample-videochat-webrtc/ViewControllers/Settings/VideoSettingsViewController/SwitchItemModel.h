//
//  SwitchItemModel.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "BaseItemModel.h"

@interface SwitchItemModel : BaseItemModel

- (instancetype)initWithTitle:(NSString *)title data:(id)data on:(BOOL)on;
- (instancetype)initWithTitle:(NSString *)title data:(id)data on:(BOOL)on changedBlock:(void(^)(BOOL isOn))changedBlock;

@property (assign, nonatomic) BOOL on;
@property (copy, nonatomic) void (^changedBlock)(BOOL on);

@end
