//
//  ChatCellLayoutAttributes.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatCellLayoutAttributes.h"

@implementation ChatCellLayoutAttributes
//MARK: - Lifecycle

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    }
    return self;
}

- (void)dealloc {
}

//MARK: - Setters

- (void)setContainerSize:(CGSize)containerSize {
    
    NSParameterAssert(containerSize.width >= 0.0f && containerSize.height >= 0.0f);
    _containerSize = [self correctedSizeFromSize:containerSize];
}

- (void)setAvatarSize:(CGSize)avatarSize {
    _avatarSize = [self correctedSizeFromSize:avatarSize];
}

//MARK: - Utilities

- (CGSize)correctedSizeFromSize:(CGSize)size {
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

//MARK: - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        
        return NO;
    }
    
    if (self.representedElementCategory == UICollectionElementCategoryCell) {
        
        ChatCellLayoutAttributes *layoutAttributes = (ChatCellLayoutAttributes *)object;
        
        if (!CGSizeEqualToSize(layoutAttributes.containerSize, self.containerSize)
            ||!CGSizeEqualToSize(layoutAttributes.avatarSize, self.avatarSize)
            ||!UIEdgeInsetsEqualToEdgeInsets(layoutAttributes.containerInsets, self.containerInsets)
            ||(int)layoutAttributes.topLabelHeight != (int)self.topLabelHeight
            ||(int)layoutAttributes.bottomLabelHeight != (int)self.bottomLabelHeight
            || (int)layoutAttributes.spaceBetweenTopLabelAndTextView != (int)self.spaceBetweenTopLabelAndTextView
            || (int)layoutAttributes.spaceBetweenTextViewAndBottomLabel != (int)self.spaceBetweenTextViewAndBottomLabel) {
            
            return NO;
        }
    }
    return [super isEqual:object];
}

- (NSString *)description {
    
    NSMutableString *desc = [NSMutableString stringWithString:[super description]];
    
    [desc appendFormat:@""];
    return desc.copy;
}

- (NSUInteger)hash {
    
    return [self.indexPath hash];
}

//MARK: - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    
    ChatCellLayoutAttributes *copy = [super copyWithZone:zone];
    
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

