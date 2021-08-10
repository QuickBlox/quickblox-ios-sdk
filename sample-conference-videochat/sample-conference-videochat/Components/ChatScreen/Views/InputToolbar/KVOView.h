//
//  KVOView.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVOView : UIView

@property (nonatomic, copy, nullable) void (^hostViewFrameChangeBlock)(UIView * _Nullable view, BOOL Animated);

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *inputView;

@end

NS_ASSUME_NONNULL_END
