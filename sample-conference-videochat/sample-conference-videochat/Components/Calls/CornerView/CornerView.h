//
//  CornerView.h
//  sample-conference-videochat
//
//  Created by Injoit on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CornerView : UIView

@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) CGFloat fontSize;
@property (copy, nonatomic) void(^touchesEndAction)(void);

@end
