//
//  QMAudioRecordButton.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/6/17.
//
//

#import "QMAudioRecordButton.h"
#import "QMChatResources.h"

static const CGFloat innerCircleRadius = 110.0f;
static const CGFloat outerCircleRadius = innerCircleRadius + 50.0f;
static const CGFloat outerCircleMinScale = innerCircleRadius / outerCircleRadius;

@interface QMAudioRecordButton() <UIGestureRecognizerDelegate> {
    
    CGPoint _touchLocation;
    UIPanGestureRecognizer *_panRecognizer;
    
    CGFloat _lastVelocity;
    
    bool _processCurrentTouch;
    CFAbsoluteTime _lastTouchTime;
    bool _acceptTouchDownAsTouchUp;
    
    UIWindow *_overlayWindow;
    
    UIImageView *_innerCircleView;
    UIImageView *_outerCircleView;
    UIImageView *_innerIconView;
    
    CFAbsoluteTime _animationStartTime;
    
    CADisplayLink *_displayLink;
    CGFloat _currentLevel;
    CGFloat _inputLevel;
    bool _animatedIn;
    
    bool _cancelled;
}

@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

@end

@implementation QMAudioRecordButton

//MARK: Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        super.exclusiveTouch = true;
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panRecognizer.cancelsTouchesInView = false;
        _panRecognizer.delegate = self;
        
        UIImage *iconImage = [[UIImage imageNamed:@"ic_audio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _innerIconView = [[UIImageView alloc] initWithImage:iconImage];
        _innerIconView.tintColor = [UIColor whiteColor];
        
        _iconView.image = [UIImage imageNamed:@"ic_audio"];
        [self addGestureRecognizer:_panRecognizer];
    }
    return self;
}

- (void)dealloc {
    
    _displayLink.paused = true;
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (CADisplayLink *)displayLink {
    
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate)];
        _displayLink.paused = true;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)displayLinkUpdate {
    
    NSTimeInterval t = CACurrentMediaTime();
    if (t > _animationStartTime + 0.5) {
        
        _currentLevel = _currentLevel * 0.8f + _inputLevel * 0.2f;
        CGFloat scale = outerCircleMinScale + _currentLevel * (1.0f - outerCircleMinScale);
        _outerCircleView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)_commitCompleted {
    
    if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidComplete:)])
        [self.delegate recordButtonInteractionDidComplete:_lastVelocity];
}

//MARK: Animations
- (void)animateIn {
    
    _animatedIn = true;
    _animationStartTime = CACurrentMediaTime();
    
    if (_overlayWindow == nil) {
        
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.windowLevel = 1000000000.0f;
        
        _overlayWindow.rootViewController = [[UIViewController alloc] init];
        _overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        _innerCircleView = [[UIImageView alloc] initWithImage:innerCircleImage()];
        _innerCircleView.alpha = 0.0f;
        [_overlayWindow.rootViewController.view addSubview:_innerCircleView];
        
        _outerCircleView = [[UIImageView alloc] initWithImage:outerCircleImage()];
        _outerCircleView.alpha = 0.0f;
        [_overlayWindow.rootViewController.view addSubview:_outerCircleView];
        
        _innerIconView.alpha = 0.0f;
        [_overlayWindow.rootViewController.view addSubview:_innerIconView];
    }
    
    _overlayWindow.hidden = false;
    
    dispatch_block_t block = ^{
        CGPoint centerPoint = [self.superview convertPoint:self.center toView:_overlayWindow.rootViewController.view];
        _innerCircleView.center = centerPoint;
        _outerCircleView.center = centerPoint;
        _innerIconView.center = centerPoint;
    };
    
    block();
    dispatch_async(dispatch_get_main_queue(), block);
    
    _innerCircleView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    _outerCircleView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    _innerCircleView.alpha = 0.2f;
    _outerCircleView.alpha = 0.2f;
    
    [UIView animateWithDuration:0.50
                          delay:0.0
         usingSpringWithDamping:0.45f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _innerCircleView.transform = CGAffineTransformIdentity;
                         _outerCircleView.transform = CGAffineTransformMakeScale(outerCircleMinScale, outerCircleMinScale);
                         _innerIconView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         
                     } completion:nil];
    
    [UIView animateWithDuration:0.1 animations:^{
        _innerCircleView.alpha = 1.0f;
        _iconView.alpha = 0.0f;
        _innerIconView.alpha = 1.0f;
        _outerCircleView.alpha = 1.0f;
    }];
    
    
    [self displayLink].paused = false;
}


- (void)animateOut {
    
    _animatedIn = false;
    _displayLink.paused = true;
    _currentLevel = 0.0f;
    
    [UIView animateWithDuration:0.18 animations:^{
        _innerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        _outerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        _innerIconView.transform = CGAffineTransformIdentity;
        _innerCircleView.alpha = 0.0f;
        _outerCircleView.alpha = 0.0f;
        _iconView.alpha = 1.0f;
        _innerIconView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            _overlayWindow.hidden = true;
            _overlayWindow = nil;
        }
    }];
}


//MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer {
    return true;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super continueTrackingWithTouch:touch withEvent:event])
    {
        _lastVelocity = [_panRecognizer velocityInView:self].x;
        
        if (_processCurrentTouch)
        {
            CGFloat distance = [touch locationInView:self].x - _touchLocation.x;
            
            CGFloat value = (-distance) / 100.0f;
            value = MAX(0.0f, MIN(1.0f, value));
            
            CGFloat velocity = [_panRecognizer velocityInView:self].x;
            
            if (CACurrentMediaTime() > _animationStartTime + 1.0) {
                CGFloat scale = MAX(0.4f, MIN(1.0f, 1.0f - value));
                if (scale > 0.8f) {
                    scale = 1.0f;
                } else {
                    scale /= 0.8f;
                }
                _innerCircleView.transform = CGAffineTransformMakeScale(scale, scale);
            }
            
            if (distance < -100.0f)
            {
                _cancelled = true;
                if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidCancel:)])
                    [self.delegate recordButtonInteractionDidCancel:velocity];
                
                return false;
            }
            
            if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidUpdate:)])
                [self.delegate recordButtonInteractionDidUpdate:value];
            
            return true;
        }
    }
    
    return false;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    
    if (_processCurrentTouch) {
        
        _cancelled = true;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidCancel:)]) {
                [self.delegate recordButtonInteractionDidCancel:_lastVelocity];
            }
        });
    }
    
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_processCurrentTouch) {
        
        _cancelled = true;
        
        CGFloat velocity = _lastVelocity;
        
        if (velocity < -400.0f) {
            
            if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidCancel:)])
                [self.delegate recordButtonInteractionDidCancel:_lastVelocity];
        }
        else {
            [self _commitCompleted];
        }
    }
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    
    if ([super beginTrackingWithTouch:touch withEvent:event]) {
        
        _lastVelocity = 0.0;
        
        if (ABS(CFAbsoluteTimeGetCurrent() - _lastTouchTime) < .5) {
            _processCurrentTouch = false;
            
            return false;
        }
        else {
            
            _cancelled = false;
            
            _processCurrentTouch = true;
            
            _lastTouchTime = CFAbsoluteTimeGetCurrent();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                _processCurrentTouch = !_cancelled;
                
                if (!_cancelled) {
                    
                    if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidBegin)]) {
                        [self.delegate recordButtonInteractionDidBegin];
                    }
                }
                else {
                    
                    if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidStopped)]) {
                        [self.delegate recordButtonInteractionDidStopped];
                    }
                }
            });
            
            _touchLocation = [touch locationInView:self];
        }
        
        return true;
    }
    
    return false;
}

- (void)panGesture:(UIPanGestureRecognizer *)__unused recognizer {
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (!self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    CGFloat margin = 100.0;
    CGRect hitFrame = CGRectInset(self.bounds, -margin, -margin);
    BOOL contains = CGRectContainsPoint(hitFrame, point);

    if (contains && !self.isHighlighted && event.type == UIEventTypeTouches)
    {
        self.highlighted = YES;
    }
    
    return contains;
}

//MARK: Static methods
UIColor *QMApplicationColor()
{
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:23.0f/255.0f green:208.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIImage *innerCircleImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(innerCircleRadius, innerCircleRadius), false, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, QMApplicationColor().CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, innerCircleRadius, innerCircleRadius));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

UIImage *outerCircleImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(outerCircleRadius, outerCircleRadius), false, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [QMApplicationColor() colorWithAlphaComponent:0.2f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, outerCircleRadius, outerCircleRadius));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
