//
//  BaseViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 21.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "BaseViewController.h"
#import "CallGradientView.h"

@interface BaseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) CallGradientView *containerToolBarView;
@property (strong, nonatomic) CallGradientView *topGradientView;
@property (strong, nonatomic) NSLayoutConstraint *topGradientViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerToolBarTopConstraint;
@property (strong, nonatomic) NSTimer *toolbarHideTimer;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureGUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationBarWillAppear:YES];
    [self showControls:YES];
    [self setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setupNavigationBarWillAppear:NO];
    [self invalidateHideToolbarTimer];
}

#pragma mark - These methods can be overridden in child controllers
- (void)configureNavigationBarItems {
    // configure it if necessary.
}

- (void)configureToolBar {
    // configure it if necessary.
}

- (void)setupCollectionView {
    // configure it if necessary.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
}

- (void)reloadContent {
    // configure it if necessary.
    [self.collectionView reloadData];
}

- (void)configureGUI {
    self.view.backgroundColor = UIColor.blackColor;
    
    // configure it if necessary.
    [self setupCollectionView];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat topBarHeight = self.view.window.windowScene.statusBarManager.statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    self.collectionView.contentInset = UIEdgeInsetsMake(-topBarHeight, 0.0f, 0.0f, 0.0f);
    self.collectionViewTopConstraint = [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor];
    self.collectionViewTopConstraint.constant = -topBarHeight;
    self.collectionViewTopConstraint.active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;

    self.containerToolBarView = [[CallGradientView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.containerToolBarView];
    self.containerToolBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerToolBarView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.containerToolBarView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.containerToolBarView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    self.containerToolBarTopConstraint = [self.containerToolBarView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant: -126.0f];
    self.containerToolBarTopConstraint.active = YES;
    [self.containerToolBarView.heightAnchor constraintEqualToConstant: 126.0f].active = YES;
    self.containerToolBarView.isVertical = YES;

    self.toolbar = [[ToolBar alloc] initWithFrame:CGRectZero];
    [self.containerToolBarView addSubview:self.toolbar];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolbar.leftAnchor constraintEqualToAnchor:self.containerToolBarView.leftAnchor].active = YES;
    [self.toolbar.rightAnchor constraintEqualToAnchor:self.containerToolBarView.rightAnchor].active = YES;
    [self.toolbar.topAnchor constraintEqualToAnchor:self.containerToolBarView.topAnchor].active = YES;
    [self.toolbar.heightAnchor constraintEqualToConstant: 96.0f].active = YES;

    self.topGradientView = [[CallGradientView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.topGradientView];
    self.topGradientView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topGradientView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.topGradientView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.topGradientView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    self.topGradientView.isVertical = YES;

    self.topGradientViewHeightConstraint = [self.topGradientView.heightAnchor constraintEqualToConstant: 100.0f];
    if (UIApplication.sharedApplication.windows.firstObject.windowScene.interfaceOrientation == UIInterfaceOrientationMaskLandscape) {
        self.topGradientViewHeightConstraint.constant = 56.0f;
    } else {
        self.topGradientViewHeightConstraint.constant = 100.0f;
    }
    
    self.topGradientViewHeightConstraint.active = YES;

    [self.containerToolBarView setupGradientWithFirstColor:[UIColor.blackColor colorWithAlphaComponent:0.0f] andSecondColor:[UIColor.blackColor colorWithAlphaComponent:0.7f]];
    [self.topGradientView setupGradientWithFirstColor:[UIColor.blackColor colorWithAlphaComponent:0.7f] andSecondColor:[UIColor.blackColor colorWithAlphaComponent:0.0f]];
    
    // configure it if necessary.
    [self configureToolBar];
    
    // configure it if necessary.
    [self configureNavigationBarItems];
}

- (void)setupNavigationBarWillAppear:(BOOL)isWillAppear {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    [self.navigationController.navigationBar setBackgroundImage:UIImage.new forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = UIImage.new;
    self.navigationController.navigationBar.translucent = isWillAppear;
}

- (void)setupHideToolbarTimerWithTimeInterval:(NSTimeInterval)timeInterval {
    [self invalidateHideToolbarTimer];
    self.toolbarHideTimer =[NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                            target:self
                                                          selector:@selector(hideControls)
                                                          userInfo:nil
                                                           repeats:NO];
    
}

- (void)invalidateHideToolbarTimer {
    if (self.toolbarHideTimer != nil) {
        [self.toolbarHideTimer invalidate];
        self.toolbarHideTimer = nil;
    }
}

- (void)hideControls {
    [self setupControls:NO];
}

- (void)showControls:(BOOL)isShow {
    [self setupControls:isShow];
}

- (void)setupControls:(BOOL)isShow {
    UIColor *color = isShow ? UIColor.whiteColor : UIColor.clearColor;
    
    if (isShow && self.containerToolBarView.hidden) {
        [self setupHideToolbarTimerWithTimeInterval:kHideTimeInterval];
    }
    self.navigationItem.titleView.hidden = !isShow;
    self.navigationItem.leftBarButtonItem.tintColor = color;
    self.navigationItem.rightBarButtonItem.tintColor = color;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: color};
    self.topGradientView.hidden = !isShow;
    self.containerToolBarView.hidden = YES;
    self.containerToolBarTopConstraint.constant = isShow == YES ? -126.0f : 0.0f;
    self.containerToolBarView.hidden = !isShow;
    
}

#pragma mark - Transition to size
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.topGradientView layoutSubviews];
        [self.toolbar layoutSubviews];
        [self reloadContent];
        
        if (UIApplication.sharedApplication.windows.firstObject.windowScene.interfaceOrientation != UIInterfaceOrientationPortrait) {
            self.topGradientViewHeightConstraint.constant = 56.0f;
        } else {
            self.topGradientViewHeightConstraint.constant = 100.0f;
        }
        
    } completion:nil];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UICollectionViewCell.new;
}

@end
