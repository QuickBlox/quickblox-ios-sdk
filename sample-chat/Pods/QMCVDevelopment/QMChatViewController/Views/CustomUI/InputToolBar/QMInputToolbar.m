//
//  QMInputToolbar.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMInputToolbar.h"
#import "UIView+QM.h"
#import "QMToolbarContentView.h"
#import "QMChatResources.h"

static void * kQMInputToolbarKeyValueObservingContext = &kQMInputToolbarKeyValueObservingContext;

@interface QMInputToolbar()

@property (assign, nonatomic) BOOL isObserving;
@property (nonatomic, assign, getter=isObserverAdded) BOOL observerAdded;

@end

@implementation QMInputToolbar
@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.isObserving = NO;
    self.sendButtonOnRight = YES;
    
    self.preferredDefaultHeight = 44.0f;
    
    QMToolbarContentView *toolbarContentView = [self loadToolbarContentView];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;
    
    [self addObservers];
    
    [self toggleSendButtonEnabled];
}

- (QMToolbarContentView *)loadToolbarContentView {
    
    NSArray *nibViews = [[QMChatResources resourceBundle] loadNibNamed:NSStringFromClass([QMToolbarContentView class])
                                                                 owner:nil
                                                               options:nil];
    return nibViews.firstObject;
}

- (void)dealloc {
    
    [self removeObservers];
    _contentView = nil;
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight {
    
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

#pragma mark - Actions
- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    
    if(self.isObserverAdded) {
        
        [self.superview removeObserver:self forKeyPath:@"frame" context:kQMInputToolbarKeyValueObservingContext];
        [self.superview removeObserver:self forKeyPath:@"center" context:kQMInputToolbarKeyValueObservingContext];
    }
    
    [newSuperview addObserver:self forKeyPath:@"frame" options:0 context:kQMInputToolbarKeyValueObservingContext];
    [newSuperview addObserver:self forKeyPath:@"center" options:0 context:kQMInputToolbarKeyValueObservingContext];
    self.observerAdded = YES;
    
    [super willMoveToSuperview:newSuperview];
}
- (void)leftBarButtonPressed:(UIButton *)sender {
    
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)rightBarButtonPressed:(UIButton *)sender {
    
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled {
    
    BOOL hasText = [self.contentView.textView hasText];
    BOOL hasTextAttachment = [self.contentView.textView hasTextAttachment];
    
    if (self.sendButtonOnRight) {
        
        self.contentView.rightBarButtonItem.enabled = hasText || hasTextAttachment;
    }
    else {
        
        self.contentView.leftBarButtonItem.enabled = hasText || hasTextAttachment;
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kQMInputToolbarKeyValueObservingContext) {
        
        if (object == self.contentView) {
            
            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {
                
                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {
                
                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];
                
                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self toggleSendButtonEnabled];
        }
        else if (object == self.superview && ([keyPath isEqualToString:@"frame"] ||
                                              [keyPath isEqualToString:@"center"])) {
            
            if  (self.inputToolbarFrameChangedBlock) {
                CGRect frame = self.superview.frame;
                self.inputToolbarFrameChangedBlock(frame);
            }
        }
    }
}

- (void)addObservers {
    
    if (self.isObserving) {
        return;
    }
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kQMInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kQMInputToolbarKeyValueObservingContext];
    
    self.isObserving = YES;
}

- (void)removeObservers {
    
    if(_observerAdded) {
        
        [self.superview removeObserver:self forKeyPath:@"frame" context:kQMInputToolbarKeyValueObservingContext];
        [self.superview removeObserver:self forKeyPath:@"center" context:kQMInputToolbarKeyValueObservingContext];
    }
    
    if (!self.isObserving) {
        return;
    }
    
    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kQMInputToolbarKeyValueObservingContext];
        
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kQMInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    self.isObserving = NO;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.inputToolbarFrameChangedBlock) {
        CGRect frame = self.superview.frame;
        self.inputToolbarFrameChangedBlock(frame);
    }
}

@end
