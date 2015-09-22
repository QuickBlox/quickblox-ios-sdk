//
//  QMChatContainerView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatContainerView.h"

@implementation QMChatContainerView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    
    [self drawCanvas1WithRect:rect];
}

- (void)drawCanvas1WithRect:(CGRect)rect  {
    
    if (self.highlighted) {
        
        [self.highlightColor setFill];
    }
    else {
        
        [self.bgColor setFill];
    }
    
    if (!self.arrow) {
        
         UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
        [rectanglePath fill];
        return;
    }
    
    CGFloat x = self.leftArrow ? self.arrowSize.width : CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    //// Subframes
    CGRect arrowRect = CGRectMake((self.leftArrow ?  0 : x + w - self.arrowSize.width),
                                  y + h - self.arrowSize.height,
                                  self.arrowSize.width, self.arrowSize.height);
    //// Rectangle Drawing
    UIBezierPath* rectanglePath =
    [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w - self.arrowSize.width, h)
                          byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | (self.leftArrow ? UIRectCornerBottomRight : UIRectCornerBottomLeft)
                                cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
    
    [rectanglePath closePath];
    [rectanglePath fill];
    //// arrow Drawing
    UIBezierPath* arrowPath = UIBezierPath.bezierPath;
    [arrowPath moveToPoint: CGPointMake(CGRectGetMaxX(arrowRect) + self.arrowSize.width, CGRectGetMaxY(arrowRect))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMaxY(arrowRect))];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect) - (self.leftArrow ?  0 : self.arrowSize.width), CGRectGetMaxY(arrowRect) - self.arrowSize.height)];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetMaxX(arrowRect) - self.arrowSize.width, CGRectGetMaxY(arrowRect))];
    [arrowPath closePath];
    [arrowPath fill];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        
        [self setNeedsDisplay];
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self setNeedsDisplay];
}

@end
