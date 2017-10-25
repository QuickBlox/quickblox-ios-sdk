//
//  QMBaseMediaCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/07/17.
//
//

#import "QMBaseMediaCell.h"
#import "QMMediaViewDelegate.h"
#import "QMChatResources.h"

@implementation UIButton (QMAnimated)

- (void)qm_setImage:(UIImage *)image {
    [self qm_setImage:image animated:YES];
}

- (void)qm_setImage:(UIImage *)buttonImage
           animated:(BOOL)animated  {
    
    NSParameterAssert(buttonImage);
    
    dispatch_block_t imageSetBlock = ^{
        [self setImage:buttonImage
              forState:UIControlStateNormal];
    };
    
    if (animated) {
        [UIView transitionWithView:self
                          duration:0.15
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:imageSetBlock
                        completion:nil];
    }
    else {
        imageSetBlock();
    }
}

@end

@implementation QMBaseMediaCell

@synthesize viewState = _viewState;
@synthesize messageID = _messageID;
@synthesize mediaHandler = _mediaHandler;
@synthesize duration = _duration;
@synthesize currentTime = _currentTime;
@synthesize progress = _progress;
@synthesize image = _image;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize cancellable = _cancellable;
@synthesize playable = _playable;

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.circularProgress.hideProgressIcons = YES;
    self.circularProgress.hidden = YES;
    [self.mediaPlayButton setTitle:nil forState:UIControlStateNormal];
    [self.mediaPlayButton addTarget:self
                             action:@selector(activateMedia:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self setViewState:QMMediaViewStateNotReady];
    
    UIImage *buttonImage = QMPlayButtonImageForState(_viewState);
    
    if (buttonImage) {
        [self.mediaPlayButton qm_setImage:buttonImage
                                 animated:YES];
    }
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    [self setViewState:QMMediaViewStateNotReady];
    
    self.progress = 0.0;
    self.previewImageView.image = nil;
    
    UIImage *buttonImage = QMPlayButtonImageForState(_viewState);
    
    if (buttonImage) {
        [self.mediaPlayButton qm_setImage:buttonImage
                                 animated:YES];
    }
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
              animated:(BOOL)animated {
    
    if (_currentTime == currentTime) {
        return;
    }
    
    if (currentTime > _duration) {
        currentTime = _duration;
    }
    _currentTime = currentTime;
    
    self.durationLabel.text = [self timestampString:currentTime forDuration:_duration];
}


- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [self setCurrentTime:currentTime
                animated:NO];
}

- (void)showLoadingError:(NSError *)error {
    
}

- (void)setProgress:(CGFloat)progress {
    
    if (self.viewState != QMMediaViewStateLoading) {
        return;
    }
    
    if (progress > 0.0) {
        
        self.circularProgress.hidden = NO;
        [self.circularProgress stopSpinProgressBackgroundLayer];
    }
    
    if (progress >= 1) {
        self.circularProgress.hidden = YES;
    }
    else {
        [self.circularProgress setProgress:progress];
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    
    _duration = duration;
    
    self.durationLabel.text = [self timestampString:duration];
}


- (void)setThumbnailImage:(UIImage *)image {
    
    _thumbnailImage = image;
    
    self.previewImageView.image = image;
    [self.previewImageView setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    
    _image = image;
    
    self.previewImageView.image = image;
    [self.previewImageView setNeedsLayout];
}


- (IBAction)activateMedia:(id)sender {
    
    [self.mediaHandler didTapMediaButton:self];
}

- (NSString *)timestampString:(NSTimeInterval)duration {
    
    if (duration < 60) {
        return [NSString stringWithFormat:@"0:%02d", (int)round(duration)];
    }
    else if (duration < 3600) {
        return [NSString stringWithFormat:@"%d:%02d", (int)duration / 60, (int)duration % 60];
    }
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", (int)duration / 3600, (int)duration / 60, (int)duration % 60];
}

- (NSString *)timestampString:(NSTimeInterval)currentTime
                  forDuration:(NSTimeInterval)duration
{
    
    NSString *timestampString  = nil;
    
    if (duration < 60) {
        if (currentTime < duration) {
            timestampString = [NSString stringWithFormat:@"0:%02d", (int)round(currentTime)];
        }
        else {
            timestampString = [NSString stringWithFormat:@"0:%02d", (int)ceil(currentTime)];
        }
    }
    else if (duration < 3600) {
        timestampString = [NSString stringWithFormat:@"%d:%02d", (int)currentTime / 60, (int)currentTime % 60];
    }
    else {
        timestampString = [NSString stringWithFormat:@"%d:%02d:%02d", (int)currentTime / 3600, (int)currentTime / 60, (int)currentTime % 60];
    }
    
    return timestampString;
}


- (CALayer *)maskLayerFromImage:(UIImage *)image
                      withFrame:(CGRect)frame {
    
    CALayer *layer = [CALayer layer];
    
    layer.frame = frame;
    layer.contents = (id)[image CGImage];
    layer.contentsScale = [image scale];
    layer.rasterizationScale = [image scale];
    CGSize imageSize = [image size];
    
    NSAssert(image.resizingMode == UIImageResizingModeStretch || UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero),
             @"the resizing mode of image should be stretch; if not, then its insets must be all-zero");
    
    UIEdgeInsets insets = [image capInsets];
    
    // These are lifted from what UIImageView does by experimentation. Without these exact values, the stretching is slightly off.
    const CGFloat halfPixelFudge = 0.49f;
    const CGFloat otherPixelFudge = 0.02f;
    // Convert to unit coordinates for the contentsCenter property.
    CGRect contentsCenter = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    if (insets.left > 0 || insets.right > 0) {
        contentsCenter.origin.x = ((insets.left + halfPixelFudge) / imageSize.width);
        contentsCenter.size.width = (imageSize.width - (insets.left + insets.right + 1.f) + otherPixelFudge) / imageSize.width;
    }
    if (insets.top > 0 || insets.bottom > 0) {
        contentsCenter.origin.y = ((insets.top + halfPixelFudge) / imageSize.height);
        contentsCenter.size.height = (imageSize.height - (insets.top + insets.bottom + 1.f) + otherPixelFudge) / imageSize.height;
    }
    layer.contentsGravity = kCAGravityResize;
    layer.contentsCenter = contentsCenter;
    
    return layer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    } else {
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
}

- (void)setViewState:(QMMediaViewState)viewState {
    
    if (_viewState == viewState) {
        return;
    }
    _viewState = viewState;
    
    [self updateViewWithState:viewState];
}

- (void)updateViewWithState:(QMMediaViewState)viewState {

    if (viewState == QMMediaViewStateLoading) {
        self.mediaPlayButton.hidden = !self.cancellable;
        [self.circularProgress startSpinProgressBackgroundLayer];
    }
    else {
        self.mediaPlayButton.hidden = !self.playable;
        [self.circularProgress stopSpinProgressBackgroundLayer];
    }
    
    self.circularProgress.hidden = viewState != QMMediaViewStateLoading;
    
    UIImage *buttonImage = [self imageForButtonWithState:viewState];
    if (!buttonImage) {
        buttonImage = QMPlayButtonImageForState(viewState);
    }
    
    [self.mediaPlayButton qm_setImage:buttonImage];
}

- (UIImage *)imageForButtonWithState:(QMMediaViewState)viewState {
    return nil;
}

static inline UIImage* QMPlayButtonImageForState(QMMediaViewState state) {
    
    NSString *imageName = nil;
    
    switch (state) {
            
        case QMMediaViewStateNotReady: imageName = @"ic_download"; break;
        case QMMediaViewStateReady:    imageName = @"ic_play"; break;
        case QMMediaViewStateLoading:  imageName = @"ic_cancel"; break;
        case QMMediaViewStateActive:   imageName = @"ic_pause"; break;
        case QMMediaViewStateError:    imageName = @"ic_retry"; break;
    }
    
    UIImage *buttonImage =
    [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return buttonImage;
}

@end
