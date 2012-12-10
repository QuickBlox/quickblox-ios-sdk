//
//  RateView.m
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "RateView.h"

static NSString *DefaultFullStarImageFilename = @"StarFull.png";
static NSString *DefaultEmptyStarImageFilename = @"StarEmpty.png";

static NSString *DefaultFullBigStarImageFilename = @"StarFullLarge.png";
static NSString *DefaultEmptyBigStarImageFilename = @"StarEmptyLarge.png";

@interface RateView ()

- (void)commonSetup;
- (void)handleTouchAtLocation:(CGPoint)location;
- (void)notifyDelegate;

@end

@implementation RateView

@synthesize rate = _rate;
@synthesize alignment = _alignment;
@synthesize padding = _padding;
@synthesize editable = _editable;
@synthesize fullStarImage = _fullStarImage;
@synthesize emptyStarImage = _emptyStarImage;
@synthesize delegate = _delegate;

- (RateView *)initWithFrame:(CGRect)frame {
    
    return [self initWithFrame:frame fullStar:[UIImage imageNamed:DefaultFullStarImageFilename] emptyStar:[UIImage imageNamed:DefaultEmptyStarImageFilename]];
}

- (RateView *)initWithFrameBig:(CGRect)frame {
    
    return [self initWithFrame:frame fullStar:[UIImage imageNamed:DefaultFullBigStarImageFilename] emptyStar:[UIImage imageNamed:DefaultEmptyBigStarImageFilename]];
}

- (RateView *)initWithFrame:(CGRect)frame fullStar:(UIImage *)fullStarImage emptyStar:(UIImage *)emptyStarImage {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];

        _fullStarImage = [fullStarImage retain];
        _emptyStarImage = [emptyStarImage retain];
        
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        
        _fullStarImage = [[UIImage imageNamed:DefaultFullStarImageFilename] retain];
        _emptyStarImage = [[UIImage imageNamed:DefaultEmptyStarImageFilename] retain];
        
        [self commonSetup];
    }
    return self;
}

- (void)dealloc {
    [_fullStarImage release]; _fullStarImage = nil;
    [_emptyStarImage release]; _emptyStarImage = nil;
    [super dealloc];
}

- (void)commonSetup
{
    // Include the initialization code that is common to initWithFrame:
    // and initWithCoder: here.
    _padding = 4;
    _numOfStars = 10;
    self.alignment = RateViewAlignmentLeft;
    self.editable = NO;
}

- (void)drawRect:(CGRect)rect
{
    switch (_alignment) {
        case RateViewAlignmentLeft:
        {
            _origin = CGPointMake(0, 0);
            break;
        }
        case RateViewAlignmentCenter:
        {
            _origin = CGPointMake((self.bounds.size.width - _numOfStars * _fullStarImage.size.width - (_numOfStars - 1) * _padding)/2, 0);
            break;
        }
        case RateViewAlignmentRight:
        {
            _origin = CGPointMake(self.bounds.size.width - _numOfStars * _fullStarImage.size.width - (_numOfStars - 1) * _padding, 0);
            return;
        }
    }

    float x = _origin.x;
    for(int i = 0; i < _numOfStars; i++) {
        [_emptyStarImage drawAtPoint:CGPointMake(x, _origin.y)];
        x += _fullStarImage.size.width + _padding;
    }


    float floor = floorf(_rate);
    x = _origin.x;
    for (int i = 0; i < floor; i++) {
        [_fullStarImage drawAtPoint:CGPointMake(x, _origin.y)];
        x += _fullStarImage.size.width + _padding;
    }

    if (_numOfStars - floor > 0.01) {
        UIRectClip(CGRectMake(x, _origin.y, _fullStarImage.size.width * (_rate - floor), _fullStarImage.size.height));
        [_fullStarImage drawAtPoint:CGPointMake(x, _origin.y)];
    }
}

- (void)setRate:(CGFloat)rate {
    _rate = rate;
    [self setNeedsDisplay];
    [self notifyDelegate];
}

- (void)setAlignment:(RateViewAlignment)alignment
{
    _alignment = alignment;
    [self setNeedsLayout];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.userInteractionEnabled = _editable;
}

- (void)setFullStarImage:(UIImage *)fullStarImage
{
    if (fullStarImage != _fullStarImage) {
        [_fullStarImage release];
        _fullStarImage = [fullStarImage retain];
        [self setNeedsDisplay];
    }
}

- (void)setEmptyStarImage:(UIImage *)emptyStarImage
{
    if (emptyStarImage != _emptyStarImage) {
        [_emptyStarImage release];
        _emptyStarImage = [emptyStarImage retain];
        [self setNeedsDisplay];
    }
}

- (void)handleTouchAtLocation:(CGPoint)location {
    for(int i = _numOfStars - 1; i > -1; i--) {
        if (location.x > _origin.x + i * (_fullStarImage.size.width + _padding) - _padding / 2.) {
            self.rate = i + 1;
            return;
        }
    }
    self.rate = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rateView:changedToNewRate:)]) {
        [self.delegate performSelector:@selector(rateView:changedToNewRate:)
                            withObject:self withObject:[NSNumber numberWithFloat:self.rate]];
    }
}

@end