//
//  QMHeaderCollectionReusableView.m
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMHeaderCollectionReusableView.h"
#import "QMChatResources.h"

@implementation QMHeaderCollectionReusableView

+ (UINib *)nib {
    
    return [QMChatResources nibWithNibName:NSStringFromClass([self class])];
}

+ (NSString *)cellReuseIdentifier {
    
    return NSStringFromClass([self class]);
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    layoutAttributes.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    [super applyLayoutAttributes:layoutAttributes];
}

@end
