//
//  ChatContainerView.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatContainerView : UIView

@property (strong, nonatomic) IBInspectable UIColor *bgColor;
@property (strong, nonatomic) IBInspectable UIColor *highlightColor;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;
@property (assign, nonatomic) IBInspectable BOOL arrow;
@property (assign, nonatomic) IBInspectable BOOL leftArrow;
@property (assign, nonatomic) IBInspectable CGSize arrowSize;
@property (assign, nonatomic) BOOL highlighted;
@property (readonly, strong, nonatomic) UIImage *backgroundImage;
@property (readonly, strong, nonatomic) UIBezierPath *maskPath;


@end

NS_ASSUME_NONNULL_END
