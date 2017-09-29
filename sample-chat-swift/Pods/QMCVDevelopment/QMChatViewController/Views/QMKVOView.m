//
//  QMKVOView.m
//
//
//  Created by Vitaliy Gurkovsky on 10/12/16.
//
//

#import "QMKVOView.h"

static void * kQMFrameKeyValueObservingContext = &kQMFrameKeyValueObservingContext;

@interface QMKVOView()

@property (assign, nonatomic, getter=isObserverAdded) BOOL observerAdded;

@end

@implementation QMKVOView

- (void)dealloc {
    
    NSLog(@"QMKVOView dealloc");
}

#pragma mark - Actions

- (void)setCollectionView:(UICollectionView *)collectionView {
    
    _collectionView = collectionView;
    
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_0) {
        [_collectionView.panGestureRecognizer addTarget:self
                                                 action:@selector(handlePanGestureRecognizer:)];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if (self.isObserverAdded) {
        
        if (self.hostViewFrameChangeBlock) {
            self.hostViewFrameChangeBlock(newSuperview, NO);
        }
        
        [self.superview removeObserver:self
                            forKeyPath:@"center"
                               context:kQMFrameKeyValueObservingContext];
    }
    
    [newSuperview addObserver:self
                   forKeyPath:@"center"
                      options:NSKeyValueObservingOptionNew
                      context:kQMFrameKeyValueObservingContext];
    
    self.observerAdded = YES;
    
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"center"] ) {
        if (self.hostViewFrameChangeBlock) {
            self.hostViewFrameChangeBlock(self.superview,
                                          _collectionView.panGestureRecognizer.state != UIGestureRecognizerStateChanged);
        }
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    if (self.superview == nil) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        UIView *host = self.superview;
        UIView *input = self.inputView;
        
        CGRect frame = host.frame;
        const CGPoint panPoint = [gesture locationInView:input.window];
        const CGRect hostViewRect = [input convertRect:frame toView:host];
        
        if (panPoint.y >= hostViewRect.origin.y) {
            frame.origin.y += hostViewRect.origin.y - panPoint.y;
            host.frame = frame;
        }
    }
}

@end
