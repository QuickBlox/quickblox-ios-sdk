//
//  SliderItemModel.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "BaseItemModel.h"

@interface SliderItemModel : BaseItemModel

@property (nonatomic, copy) NSString *minLabel;
@property (nonatomic, copy) NSString *maxLabel;

@property (assign, nonatomic) NSUInteger maxValue;
@property (assign, nonatomic) NSUInteger currentValue;
@property (assign, nonatomic) NSUInteger minValue;

@property (assign, nonatomic, getter=isDisabled) BOOL disable;

@end
