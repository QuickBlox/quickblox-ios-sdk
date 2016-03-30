//
//  OutgoingCallViewControllerNavTitleView.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 2/2/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "OutgoingCallViewControllerNavTitleView.h"

@implementation OutgoingCallViewControllerNavTitleView

- (instancetype)initWithTopTitle:(NSString *)topTitle middleTitle:(NSString *)middleTitle frame:(CGRect)frame {
	self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];

	if (self) {
		
		[self setFrame:frame];
		
		self.toplabel.text = [topTitle copy];
		self.middlelabel.text = [middleTitle copy];
	}
	return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(
					  MAX(CGRectGetWidth(self.toplabel.bounds), CGRectGetWidth(self.middlelabel.bounds)) /* space between icon and text */,
					  CGRectGetHeight(self.toplabel.bounds) + CGRectGetHeight(self.middlelabel.bounds)
					  );
}


@end
