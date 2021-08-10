//
//  BaseViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 21.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "ToolBar.h"
#import "Log.h"
@import ReplayKit;

NS_ASSUME_NONNULL_BEGIN

static const NSTimeInterval kHideTimeInterval = 5.0f;

@interface BaseViewController : UIViewController
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSLayoutConstraint *collectionViewTopConstraint;
@property (strong, nonatomic) ToolBar *toolbar;

- (void)reloadContent;
- (void)setupNavigationBarWillAppear:(BOOL)isWillAppear;
- (void)showControls:(BOOL)isShow;
- (void)setupHideToolbarTimerWithTimeInterval:(NSTimeInterval)timeInterval;
- (void)invalidateHideToolbarTimer;
- (void)setupCollectionView;
- (void)configureGUI;
- (void)configureToolBar;
- (void)configureNavigationBarItems;

@end

NS_ASSUME_NONNULL_END
