//
//  QMChatCollectionViewLayoutAttributes.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCellLayoutAttributes.h"

@interface QMChatCellLayoutAttributes()

@property (strong, nonatomic) NSMutableDictionary *customAttributes;

@end

@implementation QMChatCellLayoutAttributes

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    }
    return self;
}

- (void)dealloc {
    
}

- (void)setAttribute:(id)attribure forKey:(id <NSCopying>)key {
    
    self.customAttributes[key] = attribure;
}

- (id)attributeForKey:(id <NSCopying>)key {
    
    return self.customAttributes[key];
}

#pragma mark - Setters

- (void)setContainerSize:(CGSize)containerSize {
    
    NSParameterAssert(containerSize.width >= 0.0f && containerSize.height >= 0.0f);
    _containerSize = [self correctedSizeFromSize:containerSize];
}

- (void)setAvatarSize:(CGSize)avatarSize {
    
    _avatarSize = [self correctedSizeFromSize:avatarSize];
}

#pragma  mark - Utilites

- (CGSize)correctedSizeFromSize:(CGSize)size {
    
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    
    if (self == object) {
        
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        
        return NO;
    }
    
    if (self.representedElementCategory == UICollectionElementCategoryCell) {
        
        QMChatCellLayoutAttributes *layoutAttributes = (QMChatCellLayoutAttributes *)object;
        
        if (!CGSizeEqualToSize(layoutAttributes.containerSize, self.containerSize)
            ||(int)layoutAttributes.topLabelHeight != (int)self.topLabelHeight
            ||(int)layoutAttributes.bottomLabelHeight != (int)self.bottomLabelHeight
            ||!CGSizeEqualToSize(layoutAttributes.avatarSize, self.avatarSize)
            ||!UIEdgeInsetsEqualToEdgeInsets(layoutAttributes.containerInsets, self.containerInsets)
            || (int)layoutAttributes.spaceBetweenTopLabelAndTextView != (int)self.spaceBetweenTopLabelAndTextView
            || (int)layoutAttributes.spaceBetweenTextViewAndBottomLabel != (int)self.spaceBetweenTextViewAndBottomLabel) {
            
            return NO;
        }
    }
    return [super isEqual:object];
}

- (NSUInteger)hash {
    
    return [self.indexPath hash];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    QMChatCellLayoutAttributes *copy = [super copyWithZone:zone];
    
    if (copy.representedElementCategory != UICollectionElementCategoryCell) {
        
        return copy;
    }
    
    copy.avatarSize = self.avatarSize;
    copy.containerSize = self.containerSize;
    copy.containerInsets = self.containerInsets;
    copy.bottomLabelHeight = self.bottomLabelHeight;
    copy.topLabelHeight = self.topLabelHeight;
    copy.spaceBetweenTextViewAndBottomLabel = self.spaceBetweenTextViewAndBottomLabel;
    copy.spaceBetweenTopLabelAndTextView = self.spaceBetweenTopLabelAndTextView;
    
    return copy;
}

@end
