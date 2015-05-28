//
//  CornerView.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 5/26/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "CornerView.h"

@implementation CornerView

- (instancetype)initWithCoder:(NSCoder *)coder {
	
	self = [super initWithCoder:coder];
	if (self) {
		[self defaultStyle];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self) {
		[self defaultStyle];
	}
	return self;
}

- (void)defaultStyle {
	
	[self setContentMode:UIViewContentModeRedraw];
	self.backgroundColor = [UIColor clearColor];
	self.userInteractionEnabled = NO;
	
	_bgColor = [UIColor clearColor];
	_cornerRadius = 6;
	_fontSize = 16;
}

- (void)drawWithBgColor:(UIColor *)bgColor
		   cornerRadius:(CGFloat)cornerRadius
				   rect:(CGRect)rect
				   text:(NSString*)text
			   fontSize:(CGFloat)fontSize {
	
	UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect
															 cornerRadius:cornerRadius];
	[bgColor setFill];
	[rectanglePath fill];
	
	NSMutableParagraphStyle *style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
	style.alignment = NSTextAlignmentCenter;
	
	NSDictionary* rectangleFontAttributes = @{
											  NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: fontSize],
											  NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName:style
											  };
	CGRect rectOffset = CGRectOffset(rect,
									 0,
									 (CGRectGetHeight(rect) - [text boundingRectWithSize:rect.size
																				 options:NSStringDrawingUsesLineFragmentOrigin
																			  attributes:rectangleFontAttributes context: nil].size.height) / 2);
	[text drawInRect:rectOffset
	  withAttributes:rectangleFontAttributes];
}

- (void)drawRect:(CGRect)rect {
	
	[self drawWithBgColor:self.bgColor
			 cornerRadius:self.cornerRadius
					 rect:self.bounds
					 text:self.title
				 fontSize:self.fontSize];
}

#pragma mark - Setters

- (void)setBgColor:(UIColor *)bgColor {
	
	if( ![_bgColor isEqual:bgColor] ) {
		_bgColor = bgColor;
		
		[self setNeedsDisplay];
	}
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	
	if( _cornerRadius != cornerRadius ) {
		_cornerRadius = cornerRadius;
		
		[self setNeedsDisplay];
	}
}

- (void)setFontSize:(CGFloat)fontSize {
	
	if( _fontSize != fontSize ) {
		_fontSize = fontSize;
		
		[self setNeedsDisplay];
	}
}

- (void)setTitle:(NSString *)title {
	
	if( ![_title isEqualToString:title] ) {
		_title = title;
		
		[self setNeedsDisplay];
	}
}

#pragma mark - Action

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesEnded:touches withEvent:event];
	__weak __typeof(self)weakSelf = self;
	
	[UIView animateWithDuration:0.4
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^
	 {
		 weakSelf.alpha = 0.0f;
		 
	 } completion:^(BOOL finished) {
		 
		 if (self.touchesEndAction) {
			 self.touchesEndAction();
		 }
	 }];
}

@end