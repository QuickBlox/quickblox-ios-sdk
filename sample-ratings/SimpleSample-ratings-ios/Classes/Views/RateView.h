//
//  RateView.h
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents ratings view with stars
//

@protocol RateViewDelegate;

typedef enum {
    RateViewAlignmentLeft,
    RateViewAlignmentCenter,
    RateViewAlignmentRight
} RateViewAlignment;


@interface RateView : UIView {
    UIImage *_fullStarImage;
    UIImage *_emptyStarImage;
    CGPoint _origin;
    NSInteger _numOfStars;
}

@property(nonatomic, assign) RateViewAlignment alignment;
@property(nonatomic, assign) CGFloat rate;
@property(nonatomic, assign) CGFloat padding;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, retain) UIImage *fullStarImage;
@property(nonatomic, retain) UIImage *emptyStarImage;
@property(nonatomic, assign) NSObject<RateViewDelegate> *delegate;

- (RateView *)initWithFrame:(CGRect)frame;
- (RateView *)initWithFrameBig:(CGRect)frame;
- (RateView *)initWithFrame:(CGRect)rect fullStar:(UIImage *)fullStarImage emptyStar:(UIImage *)emptyStarImage;

@end


@protocol RateViewDelegate
- (void)rateView:(RateView *)rateView changedToNewRate:(NSNumber *)rate;
@end
