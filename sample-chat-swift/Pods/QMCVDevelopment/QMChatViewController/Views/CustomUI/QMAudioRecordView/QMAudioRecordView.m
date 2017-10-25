//
//  QMAudioRecordView.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/7/17.
//
//

#import "QMAudioRecordView.h"
#import "QMAudioRecordButton.h"
#import "QMChatResources.h"
#import "UIImage+QM.h"
#import "QMChatResources.h"
#import <mach/mach_time.h>

@interface QMAudioRecordView() {
    
    NSUInteger _audioRecordingDurationSeconds;
    NSUInteger _audioRecordingDurationMilliseconds;
    NSUInteger _audioRecordingMaximumDurationSeconds;
    NSUInteger _maxDurationWarningLimit;
    
    NSTimer *_audioRecordingTimer;
    
    UIImageView *_recordIndicatorView;
    UILabel *_recordDurationLabel;
    
    UIImageView *_slideToCancelArrow;
    UILabel *_slideToCancelLabel;
    
    CFAbsoluteTime _recordingInterfaceShowTime;
}

@property (weak, nonatomic) IBOutlet UIView *recordElementsView;

@property IBOutlet UIImageView *recordIndicatorView;
@property IBOutlet UILabel *recordDurationLabel;
@property IBOutlet UILabel *errorMessageLabel;
@property IBOutlet UILabel *slideToCancelLabel;

@end

@implementation QMAudioRecordView

+ (instancetype)loadAudioRecordView {
    
    NSArray *nibViews = [[QMChatResources resourceBundle] loadNibNamed:NSStringFromClass([self class])
                                                                 owner:nil
                                                               options:nil];
    return nibViews.firstObject;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self commonInit];
}

- (void)dealloc {
    [self stopAudioRecordingTimer];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.backgroundColor = self.superview.backgroundColor;
    
    _maxDurationWarningLimit = 4;
    
    _recordDurationLabel.backgroundColor = self.backgroundColor;
    _recordDurationLabel.textColor = [UIColor blackColor];
    _recordDurationLabel.font = [UIFont systemFontOfSize:16.0];
    _recordDurationLabel.text = @"0:00,00 ";
    _recordDurationLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImage *indicatorImage = circleImage(CGRectGetWidth(_recordIndicatorView.frame), [UIColor redColor]);
    
    _recordIndicatorView.image = indicatorImage;
    _recordIndicatorView.alpha = 0.0f;
    
    _slideToCancelLabel.backgroundColor = self.backgroundColor;
    _slideToCancelLabel.textColor = [UIColor grayColor];
    _slideToCancelLabel.font = [UIFont systemFontOfSize:14.0];
    
    _recordElementsView.hidden = NO;
    
    _errorMessageLabel.textColor = [UIColor grayColor];
    _errorMessageLabel.hidden = YES;
    _errorMessageLabel.backgroundColor = self.backgroundColor;
}


- (void)setShowRecordingInterface:(BOOL)show velocity:(CGFloat)velocity
{
    
    CGFloat avoidOffset = 400.0f;
    
    if (show) {
        
        _recordingInterfaceShowTime = CFAbsoluteTimeGetCurrent();
        
        
        _recordIndicatorView.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
        _recordDurationLabel.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
        
        _slideToCancelLabel.transform = CGAffineTransformMakeTranslation(avoidOffset, 0.0f);
        
        _recordDurationLabel.text = @"0:00,00";
        
        [_recordIndicatorView.layer removeAllAnimations];
        [_recordDurationLabel.layer removeAllAnimations];
        
        _slideToCancelLabel.transform = CGAffineTransformMakeTranslation(300.0f, 0.0f);
        
        int animationCurveOption = 7 << 16;
        
        [UIView animateWithDuration:0.25 delay:0.06 options:animationCurveOption animations:^{
            _recordIndicatorView.alpha = 1.0f;
            _recordIndicatorView.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:animationCurveOption animations:^{
            _recordDurationLabel.alpha = 1.0f;
            _recordDurationLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        [UIView animateWithDuration:0.18
                              delay:0.04
                            options:animationCurveOption
                         animations:^{
                             _slideToCancelLabel.alpha = 1.0f;
                             _slideToCancelLabel.transform = CGAffineTransformIdentity;
                         } completion:nil];
        
        [self addRecordingDotAnimation];
    }
    else {
        
        [self removeDotAnimation];
        
        NSTimeInterval durationFactor = MIN(0.4, MAX(1.0, velocity / 1000.0));
        
        int options = 0;
        
        if (ABS(CFAbsoluteTimeGetCurrent() - _recordingInterfaceShowTime) < 0.2) {
            options = UIViewAnimationOptionBeginFromCurrentState;
        }
        
        int animationCurveOption = 7 << 16;
        [UIView animateWithDuration:0.25 * durationFactor
                              delay:0.0
                            options:options | animationCurveOption
                         animations:^{
                             
                             _recordIndicatorView.alpha = 0.5f;
                             _recordIndicatorView.transform = CGAffineTransformMakeTranslation(-90.0f, 0.0f);
                         }
                         completion:^(BOOL finished) {
                             if (finished){
                                 [_recordIndicatorView removeFromSuperview];
                             }
                         }];
        
        [UIView animateWithDuration:0.25 * durationFactor
                              delay:0.05 * durationFactor
                            options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOption
                         animations:^ {
                             
                             _recordDurationLabel.alpha = 0.0f;
                             _recordDurationLabel.transform = CGAffineTransformMakeTranslation(-90.0f, 0.0f);
                             
                         } completion:^(BOOL finished) {
                             
                             if (finished){
                                 [_recordDurationLabel removeFromSuperview];
                             }
                         }];
        
        [UIView animateWithDuration:0.2 * durationFactor
                              delay:0.05 * durationFactor
                            options:UIViewAnimationOptionBeginFromCurrentState | animationCurveOption
                         animations:^ {
                             
                             _slideToCancelLabel.alpha = 0.0f;
                             _slideToCancelLabel.transform = CGAffineTransformMakeTranslation(-200, 0.0f);
                         } completion:nil];
    }
}

- (void)updateInterfaceWithVelocity:(CGFloat)velocity {
    
    CGFloat offset = velocity * 100.0f;
    
    offset = MAX(0.0f, offset - 5.0f);
    
    if (velocity < 0.3f) {
        offset = velocity / 0.6f * offset;
    }
    else {
        offset -= 0.15f * 100.0f;
    }
    
    CGAffineTransform labelTransform = CGAffineTransformIdentity;
    labelTransform = CGAffineTransformTranslate(labelTransform, -offset, 0.0f);
    _slideToCancelLabel.transform = labelTransform;
    
    CGAffineTransform indicatorTransform = CGAffineTransformIdentity;
    CGAffineTransform durationTransform = CGAffineTransformIdentity;
    
    CGFloat freeOffsetLimit = 1;
    
    if (offset > freeOffsetLimit)
    {
        indicatorTransform = CGAffineTransformMakeTranslation(freeOffsetLimit - offset, 0.0f);
        durationTransform = CGAffineTransformMakeTranslation(freeOffsetLimit - offset, 0.0f);
    }
    
    if (!CGAffineTransformEqualToTransform(indicatorTransform, _recordIndicatorView.transform))
        _recordIndicatorView.transform = indicatorTransform;
    
    if (!CGAffineTransformEqualToTransform(durationTransform, _recordDurationLabel.transform))
        _recordDurationLabel.transform = durationTransform;
}

UIImage *circleImage(CGFloat radius, UIColor *color) {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)audioRecordingStarted {
    
    [self startAudioRecordingTimer];
}

- (void)audioRecordingFinished {
    
    [self stopAudioRecordingTimer];
}

- (void)startAudioRecordingTimer {
    
    _recordDurationLabel.text = @"0:00,00";
    _recordDurationLabel.textColor = [UIColor blackColor];
    
    _audioRecordingDurationSeconds = 0;
    _audioRecordingDurationMilliseconds = 0.0;
    _audioRecordingTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0 /60.0]
                                                    interval:2.0 /60.0
                                                      target:self
                                                    selector:@selector(audioTimerEvent)
                                                    userInfo:nil
                                                     repeats:false];
    
    if ([self.delegate respondsToSelector:@selector(maximumDuration)]) {
        _audioRecordingMaximumDurationSeconds = [self.delegate maximumDuration];
    }
    
    [[NSRunLoop mainRunLoop] addTimer:_audioRecordingTimer forMode:NSRunLoopCommonModes];
}

- (void)showErrorMessage:(NSString *)errorMessage completion:(void(^)())completion {
    
    _errorMessageLabel.alpha = 0.0;
    _errorMessageLabel.hidden = NO;
    _errorMessageLabel.text = errorMessage;
    
    _recordElementsView.hidden = YES;
    
    [UIView animateWithDuration:0.25 delay:0.06 options:0 animations:^{
        
        _errorMessageLabel.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}

- (void)audioTimerEvent {
    
    if (_audioRecordingTimer != nil) {
        
        [_audioRecordingTimer invalidate];
        _audioRecordingTimer = nil;
    }
    
    NSTimeInterval recordingDuration = 0.0;
    if ([self.delegate respondsToSelector:@selector(currentDuration)]) {
        recordingDuration = [self.delegate currentDuration];
    }
    
    CFAbsoluteTime currentTime = MTAbsoluteSystemTime();
    NSUInteger currentAudioDurationSeconds = (NSUInteger)recordingDuration;
    NSUInteger currentAudioDurationMilliseconds = (int)(recordingDuration * 100.0f) % 100;
    
    if (currentAudioDurationSeconds == _audioRecordingDurationSeconds && currentAudioDurationMilliseconds == _audioRecordingDurationMilliseconds)
    {
        NSTimeInterval interval = MAX(0.01, _audioRecordingDurationSeconds + 2.0 / 60.0 - currentTime);
        
        _audioRecordingTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:interval] interval:interval target:self selector:@selector(audioTimerEvent) userInfo:nil repeats:false];
        [[NSRunLoop mainRunLoop] addTimer:_audioRecordingTimer forMode:NSRunLoopCommonModes];
    }
    else {
        
        if (_audioRecordingMaximumDurationSeconds > 0 && _audioRecordingMaximumDurationSeconds - _audioRecordingDurationSeconds <= _maxDurationWarningLimit) {
            
            NSInteger secondsLeft = _audioRecordingMaximumDurationSeconds - _audioRecordingDurationSeconds;
            if (secondsLeft == 0) {
                currentAudioDurationSeconds = _audioRecordingMaximumDurationSeconds;
                currentAudioDurationMilliseconds = 0;
            }
            
            CGFloat intensityStep = 255.0/_maxDurationWarningLimit;
            CGFloat redColorIntensity = intensityStep * (_maxDurationWarningLimit - secondsLeft);
            
            _recordDurationLabel.textColor = [UIColor colorWithRed:redColorIntensity/255.0f green:0.0f blue:0.0f alpha:1.0f];
            
            if (secondsLeft == 0) {
                currentAudioDurationSeconds = _audioRecordingMaximumDurationSeconds;
                currentAudioDurationMilliseconds = 0;
                
                _audioRecordingDurationSeconds = currentAudioDurationSeconds;
                _audioRecordingDurationMilliseconds = currentAudioDurationMilliseconds;
                _recordDurationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d,%02d", (int)_audioRecordingDurationSeconds / 60, (int)_audioRecordingDurationSeconds % 60, (int)_audioRecordingDurationMilliseconds];
                
                [self.delegate shouldStopRecordingByTimeOut];
                [self removeDotAnimation];
                [self stopAudioRecordingTimer];
                
                return;
            }
        }
        
        _audioRecordingDurationSeconds = currentAudioDurationSeconds;
        _audioRecordingDurationMilliseconds = currentAudioDurationMilliseconds;
        _recordDurationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d,%02d", (int)_audioRecordingDurationSeconds / 60, (int)_audioRecordingDurationSeconds % 60, (int)_audioRecordingDurationMilliseconds];
        
        
        NSTimeInterval interval = 2.0 / 60.0;
        _audioRecordingTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:interval] interval:interval target:self selector:@selector(audioTimerEvent) userInfo:nil repeats:false];
        [[NSRunLoop mainRunLoop] addTimer:_audioRecordingTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAudioRecordingTimer
{
    if (_audioRecordingTimer != nil)
    {
        [_audioRecordingTimer invalidate];
        _audioRecordingTimer = nil;
    }
}

- (void)addRecordingDotAnimation {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = @[@.3f, @1];
    animation.keyTimes = @[@.0, @1];
    animation.duration = 0.6;
    animation.autoreverses = true;
    animation.repeatCount = INFINITY;
    
    [_recordIndicatorView.layer addAnimation:animation forKey:@"opacity-dot"];
}

- (void)removeDotAnimation {
    
    [_recordIndicatorView.layer removeAnimationForKey:@"opacity-dot"];
}

CFAbsoluteTime MTAbsoluteSystemTime() {
    
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        mach_timebase_info(&s_timebase_info);
    }
    
    return ((CFAbsoluteTime)(mach_absolute_time() * s_timebase_info.numer)) / (s_timebase_info.denom * NSEC_PER_SEC);
}

@end
