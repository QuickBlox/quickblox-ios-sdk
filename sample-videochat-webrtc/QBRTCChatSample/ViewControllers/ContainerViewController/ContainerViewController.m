//
//  ContainerViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 18.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ContainerViewController.h"

NSString *const kVideoCallViewControllerSegueIdentifier = @"VideoCallViewController";
NSString *const kCallViewControllerSegueIdentifier = @"CallViewController";

/** A UIViewControllerContextTransitioning class to be provided transitioning delegates.
 @discussion Because we are a custom UIVievController class, with our own containment implementation, we have to provide an object conforming to the UIViewControllerContextTransitioning protocol. The system view controllers use one provided by the framework, which we cannot configure, let alone create. This class will be used even if the developer provides their own transitioning objects.
 @note The only methods that will be called on objects of this class are the ones defined in the UIViewControllerContextTransitioning protocol. The rest is our own private implementation.
 */

@interface TransitionContext : NSObject <UIViewControllerContextTransitioning>

/**
 *  Designated initializer.
 *
 *  @param fromViewController from UIViewController instance
 *  @param toViewController   to UIViewControllerInstance
 *  @param goingRight         is Goint right
 *
 *  @return return instance
 */
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController
                                goingRight:(BOOL)goingRight;
/**
 *  A block of code we can set to execute after having received the completeTransition: message.
 */
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);

/**
 *  Private setter for the animated property
 */
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
/**
 *  Private setter for the interactive property.
 */
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@end

/** Instances of this class perform the default transition animation which is to slide child views horizontally.
 @note The class only supports UIViewControllerAnimatedTransitioning at this point. Not UIViewControllerInteractiveTransitioning.
 */
@interface AnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    
    NSParameterAssert ([viewControllers count] > 0);
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.selectedViewController = (self.selectedViewController ?: self.viewControllers[0]);
}

- (BOOL)next {
    
    if (self.selectedViewController) {
        
        NSUInteger idx = [self.viewControllers indexOfObject:self.selectedViewController];
        
        if (idx == NSNotFound) {
            
            return NO;
        }
        else {
            
            if (self.viewControllers.count -1 <= idx) {
                return NO;
            }
            else {
                
                self.selectedViewController = self.viewControllers[idx + 1];
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    
    NSParameterAssert (selectedViewController);
    [self _transitionToChildViewController:selectedViewController];
    _selectedViewController = selectedViewController;
}

- (void)_transitionToChildViewController:(UIViewController *)toViewController {
    
    UIViewController *fromViewController =
    ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    
    if (toViewController == fromViewController ||
        ![self isViewLoaded]) {
        
        return;
    }
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    toViewController.view.autoresizingMask = self.view.autoresizingMask;
    toViewController.view.frame = self.view.bounds;
    
    
    // If this is the initial presentation, add the new child with no animation.
    if (!fromViewController) {
        
        [self.view addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        
        return;
    }
    
    //Animate the transition by calling the animator with our private transition context.
    //If we don't have a delegate, or if it doesn't return an animated transitioning object,
    //we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
        
        animator = [self.delegate containerViewController:self
       animationControllerForTransitionFromViewController:fromViewController
                                         toViewController:toViewController];
    }
    
    animator = (animator ?: [[AnimatedTransition alloc] init]);
    
    // Because of the nature of our view controller, with horizontally arranged buttons,
    //we instantiate our private transition context with information about whether this is
    //a left-to-right or right-to-left transition. The animator can use this information if it wants.
    NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
    NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
    
    TransitionContext *transitionContext =
    [[TransitionContext alloc] initWithFromViewController:fromViewController
                                         toViewController:toViewController
                                               goingRight:toIndex > fromIndex];
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
    };
    
    [animator animateTransition:transitionContext];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end

#pragma mark - Private Transitioning Classes

@interface TransitionContext ()

@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;

@end

@implementation TransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController
                                goingRight:(BOOL)goingRight {
    
    NSAssert ([fromViewController isViewLoaded] &&
              fromViewController.view.superview,
              @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        
        self.privateViewControllers =
        @{
          UITransitionContextFromViewControllerKey:fromViewController,
          UITransitionContextToViewControllerKey:toViewController,
          };
        
        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    return self;
}

- (UIView *)viewForKey:(NSString *)key {
    return [self viewForKey:key];
}

- (CGAffineTransform)targetTransform {
    return self.targetTransform;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    }
    else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    }
    else {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    
    if (self.completionBlock) {
        
        self.completionBlock (didComplete);
    }
}

/**
 *  Our non-interactive transition can't be cancelled (it could be interrupted, though)
 *
 *  @return Bool value
 */
- (BOOL)transitionWasCancelled { return NO; } //

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end

@implementation AnimatedTransition

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 1;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // When sliding the views horizontally in and out, figure out whether we are going left or right.
    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x <
                       [transitionContext finalFrameForViewController:toViewController].origin.x);
    
    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformInvert (travel);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:kDamping
          initialSpringVelocity:kInitialSpringVelocity
                        options:0x00
                     animations:^{
                         
                         fromViewController.view.transform = travel;
                         fromViewController.view.alpha = 0;
                         toViewController.view.transform = CGAffineTransformIdentity;
                         toViewController.view.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         fromViewController.view.transform = CGAffineTransformIdentity;
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end

@implementation UIViewController(ContainerViewController)

@dynamic containerViewController;

- (ContainerViewController *)containerViewController {
    
    if ([self.parentViewController isKindOfClass:[ContainerViewController class]]) {
        return (ContainerViewController *)self.parentViewController;
    }
    NSAssert(nil, @"Need update this case");
    
    return nil;
}

@end
