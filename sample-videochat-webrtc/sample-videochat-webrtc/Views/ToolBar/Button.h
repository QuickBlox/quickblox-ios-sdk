//
//  Button.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Button : UIButton

@property (strong, nonatomic) UIImageView *iconView;

@property (nonatomic, assign, getter=isPushed) BOOL pushed;
@property (nonatomic, assign) BOOL pressed;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *textColor;

@end
