//
//  QMKeyboardController.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMKeyboardController.h"

NSString * const QMKeyboardControllerNotificationKeyboardDidChangeFrame = @"QBChatMessageKeyboardControllerNotificationKeyboardDidChangeFrame";
NSString * const QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame = @"QBChatMessageKeyboardControllerUserInfoKeyKeyboardDidChangeFrame";

static void * kQMKeyboardControllerKeyValueObservingContext = &kQMKeyboardControllerKeyValueObservingContext;

@interface QMKeyboardController()

@property (assign, nonatomic) BOOL isObserving;
@property (weak, nonatomic) UIView *keyboardView;

@end

@implementation QMKeyboardController

#pragma mark - Initialization

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<QMKeyboardControllerDelegate>)delegate {
    
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);
    NSParameterAssert(panGestureRecognizer != nil);
    
    self = [super init];
    if (self) {
        
        _textView = textView;
        _contextView = contextView;
        _panGestureRecognizer = panGestureRecognizer;
        _delegate = delegate;
        _isObserving = NO;
    }
    return self;
}

- (void)dealloc {
    
    [self removeKeyboardFrameObserver];
    [self unregisterForNotifications];
    _textView = nil;
    _contextView = nil;
    _panGestureRecognizer = nil;
    _delegate = nil;
    _keyboardView = nil;
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView {
    
    if (_keyboardView) {
        
        [self removeKeyboardFrameObserver];
    }
    
    _keyboardView = keyboardView;
    
    if (keyboardView && !_isObserving) {
        
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:kQMKeyboardControllerKeyValueObservingContext];
        
        _isObserving = YES;
    }
}

#pragma mark - Getters

- (BOOL)keyboardIsVisible {
    
    return self.keyboardView != nil;
}

- (CGRect)currentKeyboardFrame {
    
    if (!self.keyboardIsVisible) {
        
        return CGRectNull;
    }
    
    return self.keyboardView.frame;
}

#pragma mark - Keyboard controller

- (void)beginListeningForKeyboard {
    
    if (self.textView.inputAccessoryView == nil) {
        self.textView.inputAccessoryView = [[UIView alloc] init];
    }
    
    [self registerForNotifications];
}

- (void)endListeningForKeyboard {
    
    [self unregisterForNotifications];
    
    [self setKeyboardViewHidden:NO];
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)registerForNotifications {
    
    [self unregisterForNotifications];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveKeyboardDidShowNotification:)
                          name:UIKeyboardDidShowNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveKeyboardWillChangeFrameNotification:)
                          name:UIKeyboardWillChangeFrameNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveKeyboardDidChangeFrameNotification:)
                          name:UIKeyboardDidChangeFrameNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveKeyboardDidHideNotification:)
                          name:UIKeyboardDidHideNotification
                        object:nil];
}

- (void)unregisterForNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveKeyboardDidShowNotification:(NSNotification *)notification {
    
    self.keyboardView = self.textView.inputAccessoryView.superview;
    [self setKeyboardViewHidden:NO];
    
    __weak __typeof(self)weakSelf = self;
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        
        [weakSelf.panGestureRecognizer addTarget:weakSelf action:@selector(handlePanGestureRecognizer:)];
    }];
}

- (void)didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification {
    
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification {
    
    [self setKeyboardViewHidden:NO];
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)didReceiveKeyboardDidHideNotification:(NSNotification *)notification {
    
    self.keyboardView = nil;
    
    __weak __typeof(self)weakSelf = self;
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        
        [weakSelf.panGestureRecognizer removeTarget:weakSelf action:NULL];
    }];
}

- (void)handleKeyboardNotification:(NSNotification *)notification completion:(void(^)(BOOL success))completion {
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^
     {
         [self notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
         
     } completion:^(BOOL finished) {
         
         if (completion) {
             
             completion(finished);
         }
     }];
}

#pragma mark - Utilities

- (void)setKeyboardViewHidden:(BOOL)hidden {
    
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)notifyKeyboardFrameNotificationForFrame:(CGRect)frame {
    
    [self.delegate keyboardController:self keyboardDidChangeFrame:frame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QMKeyboardControllerNotificationKeyboardDidChangeFrame
                                                        object:self
                                                      userInfo:@{ QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame : [NSValue valueWithCGRect:frame] }];
}

- (void)resetKeyboardAndTextView {
    
    [self setKeyboardViewHidden:YES];
    [self removeKeyboardFrameObserver];
    [self.textView resignFirstResponder];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kQMKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            CGRect keyboardEndFrameConverted =
            [self.contextView convertRect:newKeyboardFrame
                                 fromView:self.keyboardView.superview];
            
            [self notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
        }
    }
}

- (void)removeKeyboardFrameObserver
{
    if (!_isObserving) {
        return;
    }
    
    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:kQMKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _isObserving = NO;
}

#pragma mark - Pan gesture recognizer

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan {
    
    CGPoint touch = [pan locationInView:self.contextView];
    
    //  system keyboard is added to a new UIWindow, need to operate in window coordinates
    //  also, keyboard always slides from bottom of screen, not the bottom of a view
    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
        
        //  handle iOS 7 bug when rotating to landscape
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
        }
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
            
        case UIGestureRecognizerStateChanged: {
            
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            
            //  bound frame between bottom of view and height of keyboard
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (CGRectGetMinY(newKeyboardViewFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                
                [self resetKeyboardAndTextView];
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                             animations:^
             {
                 self.keyboardView.frame = newKeyboardViewFrame;
                 
             } completion:^(BOOL finished) {
                 
                 self.keyboardView.userInteractionEnabled = !shouldHide;
                 
                 if (shouldHide) {
                     [self resetKeyboardAndTextView];
                 }
             }];
        }
            break;
            
        default:break;
    }
}

@end
