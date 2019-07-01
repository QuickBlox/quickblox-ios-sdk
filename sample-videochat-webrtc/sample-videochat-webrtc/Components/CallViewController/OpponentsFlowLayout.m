//
//  CustomLayout.m
//  flowlayout
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "OpponentsFlowLayout.h"

@interface OpponentsFlowLayout()

//@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *layoutAttributes;

@end

@implementation OpponentsFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.minimumInteritemSpacing = 2;
    self.minimumLineSpacing = 2;
    self.layoutAttributes = [NSMutableArray array];
}

- (CGSize)collectionViewContentSize {
    
    return self.collectionView.frame.size;
}

- (NSInteger)numberOfColumnsWithItemsCount:(NSInteger)count isPortrait:(BOOL)isPortrait {
    
    if (!isPortrait) {
        
        switch (count) {
            case 1:
                return 1;
                break;
            case 2:
                return 2;
                break;
            case 3:
                return 3;
                break;
            case 4:
                return 2;
                break;
            case 5:
                return 3;
                break;
            case 6:
                return 3;
                break;
            case 9:
                return 3;
                break;

            default:
                return 4;
                break;
        }
    }
    
    switch (count) {
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 2;
            break;
        case 5:
            return 2;
            break;
        case 6:
            return 2;
            break;
            
        default:
            return 3;
            break;
    }
}

- (NSInteger)shiftPositionWithItemsCount:(NSInteger)itemsCount isPortrait:(BOOL)isPortrait {
    // ItemsCount : position
    if (!isPortrait) {
        
        NSDictionary *map = @{
                              @(5): @(3),
                              @(7): @(4),
                              @(10): @(8)
                              };
        NSInteger shiftPosition = [map[@(itemsCount)] integerValue];
        if (!shiftPosition) {
            return 8;
        }
        return shiftPosition;
    }

    NSDictionary *map = @{
                          @(3): @(0),
                          @(5): @(0),
                          @(7): @(6),
                          @(8): @(6),
                          @(10): @(9),
                          @(11): @(9),
                          @(13): @(12),
                          @(14): @(12)
                          };
    NSInteger shiftPosition = [map[@(itemsCount)] integerValue];
    if (!shiftPosition) {
        return 12;
    }
    return shiftPosition;
}

- (CGRect)itemFrameWithIndex:(NSInteger)index count:(NSInteger)count {
    CGSize size = [self collectionViewContentSize];
    BOOL isPortrait = size.width < size.height;

    NSInteger columnsCount = [self numberOfColumnsWithItemsCount:count isPortrait:isPortrait];
    
    if (count <= 1) {
        return CGRectMake(0.0f, 0.0f, size.width, size.height);
    }
    
    NSInteger position = [self shiftPositionWithItemsCount:count isPortrait:isPortrait];
    NSInteger shift = index > position ? 1 : 0;
    NSInteger mod = count % columnsCount;
    
    float square = (float)count;
    float side = (float)columnsCount;
    NSInteger rows = ceil(square / side);
    
    float scale = 1.0f / side;
    
    if (position == index) {
        if (columnsCount == 2) {
            scale = 1.0f;
        } else if (columnsCount == 3) {
            scale = mod == 1 ? 1.0 : (float)mod / side;
        } else if (columnsCount == 4) {
            scale = 2.0f / side;
        }
    }
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height / rows;
    float slip = (float)(index + shift);
    
    NSInteger row = floor(slip / side);
    float slipMod = (index + shift) % columnsCount;
    
    CGFloat originX = width * roundf(slipMod);
    CGFloat originY = height * row;

    return CGRectMake(originX, originY, width, height);
}

- (void)prepareLayout {
    
    [self.layoutAttributes removeAllObjects];
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    for (NSUInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        attributes.frame = [self itemFrameWithIndex:itemIndex count:numberOfItems];
        
        [self.layoutAttributes addObject:attributes];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *matchingLayoutAttributes = [NSMutableArray new];

    for (UICollectionViewLayoutAttributes *cellAttributes in self.layoutAttributes) {
        
        CGRect intersection = CGRectIntersection(rect, cellAttributes.frame);
        if (CGRectIsNull(intersection) == NO) {
            [matchingLayoutAttributes addObject:[cellAttributes copy]];
        }
    }
    return matchingLayoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
