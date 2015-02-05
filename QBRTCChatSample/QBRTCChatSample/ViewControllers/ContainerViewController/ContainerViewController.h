//
//  ContainerViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 18.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "BaseViewController.h"

@protocol ContainerViewControllerDelegate;

@interface ContainerViewController : BaseViewController

@property (weak, nonatomic) id <ContainerViewControllerDelegate> delegate;

@property (copy, nonatomic) NSArray *viewControllers;

@property (weak, nonatomic) UIViewController *selectedViewController;

- (BOOL)next;

@end

@protocol ContainerViewControllerDelegate <NSObject>

/** Informs the delegate that the user selected view controller by tapping the corresponding icon.
 * @note The method is called regardless of whether the selected view controller changed or not and
 * only as a result of the user tapped a button. The method is not called when the view controller is
 * changed programmatically. This is the same pattern as UITabBarController uses.
 */
- (void)containerViewController:(ContainerViewController *)containerViewController
        didSelectViewController:(UIViewController *)viewController;

/// Called on the delegate to obtain a UIViewControllerAnimatedTransitioning object which can be used to animate a non-interactive transition.
- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(ContainerViewController *)containerViewController
                   animationControllerForTransitionFromViewController:(UIViewController *)fromViewController
                                                     toViewController:(UIViewController *)toViewController;

@end

@interface UIViewController(ContainerViewController)

@property (weak, nonatomic, readonly) ContainerViewController *containerViewController;

@end