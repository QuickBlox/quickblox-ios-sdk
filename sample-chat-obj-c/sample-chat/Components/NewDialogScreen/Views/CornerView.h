//
//  CornerView.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CornerView : UIView

@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) CGFloat fontSize;
@property (copy, nonatomic) void(^touchesEndAction)(void);

@end

NS_ASSUME_NONNULL_END
