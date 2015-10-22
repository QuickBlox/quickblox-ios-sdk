//
//  QMChatCollectionViewLayoutAttributes.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatCellLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

@property (assign, nonatomic) UIEdgeInsets containerInsets;
@property (assign, nonatomic) CGSize containerSize;
@property (assign, nonatomic) CGSize avatarSize;
@property (assign, nonatomic) CGFloat topLabelHeight;
@property (assign, nonatomic) CGFloat bottomLabelHeight;
@property (assign, nonatomic) CGFloat spaceBetweenTopLabelAndTextView;
@property (assign, nonatomic) CGFloat spaceBetweenTextViewAndBottomLabel;

@end
