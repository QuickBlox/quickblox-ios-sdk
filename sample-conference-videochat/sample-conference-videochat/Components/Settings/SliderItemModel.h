//
//  SliderItemModel.h
//  sample-conference-videochat
//
//  Created by Injoit on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
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
