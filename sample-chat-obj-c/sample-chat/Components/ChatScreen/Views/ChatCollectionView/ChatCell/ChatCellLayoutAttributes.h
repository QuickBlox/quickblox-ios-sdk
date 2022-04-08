//
//  ChatCellLayoutAttributes.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatCellLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

@property (assign, nonatomic) UIEdgeInsets containerInsets;
@property (assign, nonatomic) CGSize containerSize;
@property (assign, nonatomic) CGSize avatarSize;
@property (assign, nonatomic) CGFloat topLabelHeight;
@property (assign, nonatomic) CGFloat bottomLabelHeight;
@property (assign, nonatomic) CGFloat spaceBetweenTopLabelAndTextView;
@property (assign, nonatomic) CGFloat spaceBetweenTextViewAndBottomLabel;

@end

NS_ASSUME_NONNULL_END
