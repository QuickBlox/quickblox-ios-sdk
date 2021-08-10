//
//  ChatCollectionView.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatCollectionView.h"

@interface ChatCollectionView ()

@end

@implementation ChatCollectionView

@dynamic dataSource;
@dynamic delegate;
@dynamic collectionViewLayout;

//MARK: - Initialization

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self configureCollectionView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureCollectionView];
}

- (void)configureCollectionView {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
}

@end
