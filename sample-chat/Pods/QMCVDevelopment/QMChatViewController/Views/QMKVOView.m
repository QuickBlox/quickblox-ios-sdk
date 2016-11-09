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
#pragma mark - Life cycle
- (void)dealloc {
    //ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}
#pragma mark - Actions

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if (self.isObserverAdded) {
        
        [self.superview removeObserver:self
                            forKeyPath:@"frame"
                               context:kQMFrameKeyValueObservingContext];
        [self.superview removeObserver:self
                            forKeyPath:@"center"
                               context:kQMFrameKeyValueObservingContext];
    }
    
    [newSuperview addObserver:self
                   forKeyPath:@"frame"
                      options:0
                      context:kQMFrameKeyValueObservingContext];
    
    [newSuperview addObserver:self
                   forKeyPath:@"center"
                      options:0
                      context:kQMFrameKeyValueObservingContext];
    
    self.observerAdded = YES;
    
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - Key-value observing

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.superFrameDidChangeBlock) {
        self.superFrameDidChangeBlock(self.superview.frame);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.superview && ([keyPath isEqualToString:@"frame"] ||
                                     [keyPath isEqualToString:@"center"])) {
        
        if  (self.superFrameDidChangeBlock) {
            self.superFrameDidChangeBlock(self.superview.frame);
        }
    }
}

@end
