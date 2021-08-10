//
//  ChatGradientView.h
//  sample-conference-videochat
//
//  Created by Injoit on 13.06.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallGradientView : UIView
@property (assign, nonatomic) Boolean isVertical;
//- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupGradientWithFirstColor:(UIColor *)firstColor andSecondColor:(UIColor *)secondColor;
@end

NS_ASSUME_NONNULL_END
