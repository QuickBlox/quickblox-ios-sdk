//
//  QMAudioRecordButton.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/6/17.
//
//

#import "QMAudioRecordButton.h"
#import "QMChatResources.h"

static const CGFloat _innerCircleRadius = 110.0f;
static const CGFloat _outerCircleRadius = _innerCircleRadius + 50.0f;
static const CGFloat _outerCircleMinScale = _innerCircleRadius / _outerCircleRadius;

@interface QMAudioRecordButton() <UIGestureRecognizerDelegate>
    
@property (nonatomic) CGPoint touchLocation;
@property (nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) CGFloat inputLevel;
@property (nonatomic) CGFloat currentLevel;
@property (nonatomic) CGFloat lastVelocity;
@property (nonatomic) CADisplayLink *displayLink;
@property (nonatomic) CFAbsoluteTime animationStartTime;
@property (nonatomic) UIImageView *innerIconView;
@property (nonatomic) UIImageView *outerCircleView;
@property (nonatomic) UIImageView *innerCircleView;
@property (nonatomic) UIWindow *overlayWindow;
@property (nonatomic) UIEdgeInsets hitTestEdgeInsets;
@property (nonatomic) CFAbsoluteTime lastTouchTime;

@property (nonatomic) BOOL acceptTouchDownAsTouchUp;
@property (nonatomic) BOOL cancelled;
@property (nonatomic) BOOL animatedIn;
@property (nonatomic) BOOL processCurrentTouch;
    
@end

@implementation QMAudioRecordButton

//MARK: Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        self.exclusiveTouch = YES;
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panRecognizer.cancelsTouchesInView = NO;
        _panRecognizer.delegate = self;
        
        UIImage *iconImage = [[QMChatResources imageNamed:@"ic_audio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _innerIconView = [[UIImageView alloc] initWithImage:iconImage];
        _innerIconView.tintColor = [UIColor whiteColor];
        
        _iconView.image = [QMChatResources imageNamed:@"ic_audio"];
        [self addGestureRecognizer:_panRecognizer];
    }
    return self;
}

- (void)dealloc {
    
    _displayLink.paused = YES;
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (CADisplayLink *)displayLink {
    
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)displayLinkUpdate {
    
    NSTimeInterval t = CACurrentMediaTime();
    if (t > _animationStartTime + 0.5) {
        
        self.currentLevel = self.currentLevel * 0.8f + self.inputLevel * 0.2f;
        CGFloat scale = _outerCircleMinScale + self.currentLevel * (1.0f - _outerCircleMinScale);
        _outerCircleView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)_commitCompleted {
    
    if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidComplete:)])
        [self.delegate recordButtonInteractionDidComplete:_lastVelocity];
}

//MARK: Animations
- (void)animateIn {
    
    self.animatedIn = YES;
    self.animationStartTime = CACurrentMediaTime();
    
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
    
    _overlayWindow.hidden = NO;
    
    CGPoint centerPoint = [self.superview convertPoint:self.center toView:_overlayWindow.rootViewController.view];
    _innerCircleView.center = centerPoint;
    _outerCircleView.center = centerPoint;
    _innerIconView.center = centerPoint;
    
    
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
                         self.innerCircleView.transform = CGAffineTransformIdentity;
                         self.outerCircleView.transform = CGAffineTransformMakeScale(_outerCircleMinScale, _outerCircleMinScale);
                         self.innerIconView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         
                     } completion:nil];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.innerCircleView.alpha = 1.0f;
        self.iconView.alpha = 0.0f;
        self.innerIconView.alpha = 1.0f;
        self.outerCircleView.alpha = 1.0f;
    }];
    
    
    [self displayLink].paused = false;
}


- (void)animateOut {
    
    self.animatedIn = false;
    self.displayLink.paused = true;
    self.currentLevel = 0.0f;
    
    [UIView animateWithDuration:0.18 animations:^{
        self.innerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        self.outerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        self.innerIconView.transform = CGAffineTransformIdentity;
        self.innerCircleView.alpha = 0.0f;
        self.outerCircleView.alpha = 0.0f;
        self.iconView.alpha = 1.0f;
        self.innerIconView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            self.overlayWindow.hidden = true;
            self.overlayWindow = nil;
        }
    }];
}


//MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer {
    return true;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if ([super continueTrackingWithTouch:touch withEvent:event])
    {
        self.lastVelocity = [self.panRecognizer velocityInView:self].x;
        
        if (_processCurrentTouch)
        {
            CGFloat distance = [touch locationInView:self].x - self.touchLocation.x;
            
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
                self.innerCircleView.transform = CGAffineTransformMakeScale(scale, scale);
            }
            
            if (distance < -100.0f)
            {
                self.cancelled = true;
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
    
    if (self.processCurrentTouch) {
        
        self.cancelled = true;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(recordButtonInteractionDidCancel:)]) {
                [self.delegate recordButtonInteractionDidCancel:self.lastVelocity];
            }
        });
    }
    
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.processCurrentTouch) {
        
        self.cancelled = true;
        
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
        
        self.lastVelocity = 0.0;
        
        if (ABS(CFAbsoluteTimeGetCurrent() - self.lastTouchTime) < .5) {
            _processCurrentTouch = false;
            
            return false;
        }
        else {
            
            self.cancelled = false;
            
            self.processCurrentTouch = true;
            
            self.lastTouchTime = CFAbsoluteTimeGetCurrent();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                self.processCurrentTouch = !self.cancelled;
                
                if (!self.cancelled) {
                    
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
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(_innerCircleRadius, _innerCircleRadius), false, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, QMApplicationColor().CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, _innerCircleRadius, _innerCircleRadius));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

UIImage *outerCircleImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(_outerCircleRadius, _outerCircleRadius), false, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [QMApplicationColor() colorWithAlphaComponent:0.2f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, _outerCircleRadius, _outerCircleRadius));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
