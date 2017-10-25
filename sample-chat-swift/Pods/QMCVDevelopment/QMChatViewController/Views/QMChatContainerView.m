//
//  QMChatContainerView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatContainerView.h"

@interface QMChatContainerView()

@property (strong, nonatomic) UIImageView *preview;
@property (readwrite, strong, nonatomic) UIBezierPath *maskPath;

@end

@implementation QMChatContainerView

static NSMutableDictionary *_imaages = nil;

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imaages = [NSMutableDictionary dictionary];
    });
}

+ (UIImage *)bubleImageWithArrowSize:(CGSize)arrowSize
                           fillColor:(UIColor *)fillColor
                        cornerRadius:(NSUInteger)cornerRadius
                           leftArrow:(BOOL)leftArrow {
    
    NSString *identifier = [NSString stringWithFormat:@"%@_%tu_%tu_%d",
                            NSStringFromCGSize(arrowSize),
                            fillColor.hash,
                            cornerRadius,
                            leftArrow];
    
    UIImage *img = _imaages[identifier];
    cornerRadius = MIN(cornerRadius, 10);
    int space = leftArrow ? arrowSize.width : 0;
    float leftCap = space +  cornerRadius + 1;
    float topCap = cornerRadius;
    
    CGSize size = CGSizeMake(arrowSize.width + (space +  cornerRadius * 2) +2,
                             cornerRadius * 2 + arrowSize.height);
    
    if (img) {
        return img;
    }
    
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [fillColor setFill];
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    BOOL arrow = arrowSize.width + arrowSize.height;
    
    UIBezierPath *rectanglePath = nil;
    if (!arrow) {
        
        rectanglePath =
        [UIBezierPath bezierPathWithRoundedRect:rect
                                   cornerRadius:cornerRadius];
    }
    else {
        
        CGFloat x = leftArrow ? arrowSize.width : CGRectGetMinX(rect);
        CGFloat y = CGRectGetMinY(rect);
        CGFloat w = CGRectGetWidth(rect);
        CGFloat h = CGRectGetHeight(rect);
        //// Subframes
        CGRect arrowRect = CGRectMake((leftArrow ?  0 : x + w - arrowSize.width),
                                      y + h - arrowSize.height,
                                      arrowSize.width, arrowSize.height);
        //// Rectangle Drawing
        rectanglePath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w - arrowSize.width, h)
                              byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | (leftArrow ? UIRectCornerBottomRight : UIRectCornerBottomLeft)
                                    cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        
        [rectanglePath moveToPoint:CGPointMake(CGRectGetMaxX(arrowRect) + arrowSize.width,
                                               CGRectGetMaxY(arrowRect))];
        
        [rectanglePath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect),
                                                  CGRectGetMaxY(arrowRect))];
        [rectanglePath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect) - (leftArrow ?  0 : arrowSize.width),
                                                  CGRectGetMaxY(arrowRect) - arrowSize.height)];
        [rectanglePath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect) - arrowSize.width,
                                                  CGRectGetMaxY(arrowRect))];
    }
    
    [rectanglePath fill];
    

    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    img = [img stretchableImageWithLeftCapWidth:leftCap
                                   topCapHeight:topCap];
    _imaages[identifier] = img;
    
    return img;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.opaque = YES;
    _preview =
    [[UIImageView alloc] initWithFrame:self.bounds];
    _preview.userInteractionEnabled = YES;
    _preview.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIImage *bubleImg =
    [QMChatContainerView bubleImageWithArrowSize:self.arrowSize
                                       fillColor:self.bgColor
                                    cornerRadius:self.cornerRadius
                                       leftArrow:self.leftArrow];
    
    _preview.image = bubleImg;
    
    _preview.highlightedImage = bubleImg;
    
    [self insertSubview:_preview atIndex:0];
}

- (UIImage *)backgroundImage {
    return _preview.image;
}

- (void)setBgColor:(UIColor *)bgColor {
    
    if (![_bgColor isEqual:bgColor]) {
        
        //awakefromnib
        if (_bgColor) {
            
            UIImage *bubleImg =
            [QMChatContainerView bubleImageWithArrowSize:self.arrowSize
                                               fillColor:bgColor
                                            cornerRadius:self.cornerRadius
                                               leftArrow:self.leftArrow];
            _preview.image = bubleImg;
        }
        
        _bgColor = bgColor;
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    
    if (![_highlightColor isEqual:highlightColor]) {
        
        if (_highlightColor) {
            
            UIImage *bubleImg =
            [QMChatContainerView bubleImageWithArrowSize:self.arrowSize
                                               fillColor:highlightColor
                                            cornerRadius:self.cornerRadius
                                               leftArrow:self.leftArrow];
            _preview.highlightedImage = bubleImg;
        }
        
        _highlightColor = highlightColor;
    }

}

- (void)setHighlighted:(BOOL)highlighted {
    
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        
        _preview.alpha = highlighted ? 0.6 : 1;
    }
}

@end
