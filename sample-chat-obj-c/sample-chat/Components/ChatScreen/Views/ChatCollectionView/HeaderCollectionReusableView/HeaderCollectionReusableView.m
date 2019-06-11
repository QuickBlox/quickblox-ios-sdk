//
//  HeaderCollectionReusableView.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "HeaderCollectionReusableView.h"
#import "ChatResources.h"

@implementation HeaderCollectionReusableView

+ (UINib *)nib {
    return [ChatResources nibWithNibName:NSStringFromClass([self class])];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    layoutAttributes.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    [super applyLayoutAttributes:layoutAttributes];
}

@end
