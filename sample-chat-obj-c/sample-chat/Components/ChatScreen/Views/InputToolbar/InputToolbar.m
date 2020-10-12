//
//  InputToolbar.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "InputToolbar.h"
#import "UIView+Chat.h"
#import "ChatResources.h"


static void * kInputToolbarKeyValueObservingContext = &kInputToolbarKeyValueObservingContext;

@interface InputToolbar()

@property (assign, nonatomic) BOOL isObserving;
@property (strong, nonatomic) UIButton *sendButton;

@end

@implementation InputToolbar
@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
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
    [self layoutIfNeeded];
    self.isObserving = NO;
    self.sendButtonOnRight = YES;
    self.preferredDefaultHeight = 44.0f;
    ToolbarContentView *toolbarContentView = [self loadToolbarContentView];
    [self addSubview:toolbarContentView];
    _contentView = toolbarContentView;
    [self setShadowImage:UIImage.new forToolbarPosition:UIBarPositionAny];
    [self pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    
    [self addObservers];
    [self toggleSendButtonEnabledIsUploaded:NO];
}


- (ToolbarContentView *)loadToolbarContentView {
    
    NSArray *nibViews = [[ChatResources resourceBundle] loadNibNamed:NSStringFromClass([ToolbarContentView class])
                                                                 owner:nil
                                                               options:nil];
    return nibViews.firstObject;
}

- (void)dealloc {
    [self removeObservers];
    [self.contentView removeFromSuperview];
    _contentView = nil;
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight {
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

#pragma mark - Actions

- (void)leftBarButtonPressed:(UIButton *)sender {
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)rightBarButtonPressed:(UIButton *)sender {
    [sender setEnabled:NO];
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleButtons {
    
    BOOL hasText = self.contentView.textView.text.length > 0;
    BOOL hasTextAttachment = [self.contentView.textView hasTextAttachment];
    BOOL hasDataToSend = hasText || hasTextAttachment;
    
    UIButton *buttonToUpdate;
    UIView *buttonContainer;
    if (self.sendButtonOnRight) {
        buttonToUpdate = self.contentView.rightBarButtonItem;
        buttonContainer = self.contentView.rightBarButtonContainerView;
    } else {
        buttonToUpdate = self.contentView.leftBarButtonItem;
        buttonContainer = self.contentView.leftBarButtonContainerView;
    }
    
    buttonToUpdate.hidden = !hasDataToSend;
    buttonToUpdate.enabled = [self.contentView.textView hasText];
}

- (void)addCenterConstraintsToItem:(UIView *)itemToAdd {

}

- (void)setupBarButtonEnabledLeft:(Boolean)left andRight:(Boolean)right {
    self.contentView.rightBarButtonItem.enabled = right;
    self.contentView.leftBarButtonItem.enabled = left;
}

- (void)toggleSendButtonEnabledIsUploaded:(BOOL)isUploaded {
    BOOL hasText = [self.contentView.textView hasText];
    if (self.sendButtonOnRight || isUploaded) {
        self.contentView.rightBarButtonItem.enabled = hasText || isUploaded;
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kInputToolbarKeyValueObservingContext) {
        
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
            
            [self toggleSendButtonEnabledIsUploaded:NO];
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
                          context:kInputToolbarKeyValueObservingContext];
    
    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kInputToolbarKeyValueObservingContext];
    
    self.isObserving = YES;
}

- (void)removeObservers {
    
    if (!self.isObserving) {
        return;
    }
    
    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kInputToolbarKeyValueObservingContext];
        
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    self.isObserving = NO;
}
@end

