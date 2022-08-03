//
//  TitleView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView
//MARK: - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = UIColor.whiteColor;
        self.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightBold];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
