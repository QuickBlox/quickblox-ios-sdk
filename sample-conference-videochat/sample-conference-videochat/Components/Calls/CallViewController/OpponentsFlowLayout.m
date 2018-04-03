//
//  CustomLayout.m
//  flowlayout
//
//  Created by Anton Sokolchenko on 10/8/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "OpponentsFlowLayout.h"

@interface OpponentsFlowLayout()
{
    NSMutableArray *_layoutAttributes;
}

@end

@implementation OpponentsFlowLayout

// MARK: Construction

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    self.minimumInteritemSpacing = 2;
    self.minimumLineSpacing = 2;
    _layoutAttributes = [[NSMutableArray alloc] init];
}

// MARK: UISubclassingHooks

- (void)prepareLayout {
    [_layoutAttributes removeAllObjects];
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < numberOfItems; ++i) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        attributes.frame = [self itemFrameWithItemIndex:i itemsCount:numberOfItems];
        [_layoutAttributes addObject:attributes];
    }
}

- (CGSize)collectionViewContentSize {
    
    return self.collectionView.frame.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (UICollectionViewLayoutAttributes *attributes in _layoutAttributes) {
        if (!CGRectIsNull(CGRectIntersection(rect, attributes.frame))) {
            [array addObject:attributes];
        }
    }
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

// MARK: Helpers

NSInteger shiftPosition(NSUInteger itemsCount, BOOL isPortrait) {
    // ItemsCount : position
    NSDictionary *map = nil;
    if (isPortrait) {
        map = @
        {
            @3 : @0,
            @5 : @0,
            @7 : @6,
            @8 : @6,
            @10 : @9,
            @11 : @9,
            @13 : @12,
            @14 : @12,
        };
    }
    else {
        map = @
        {
            @5 : @3,
            @7 : @4,
            @10 : @8,
        };
    }
    
    NSNumber *position = map[@(itemsCount)];
    
    if (position) {
        return position.integerValue;
    }
    
    return -1;
}

- (CGRect)itemFrameWithItemIndex:(NSUInteger)itemIndex
                      itemsCount:(NSUInteger)itemsCount {
    
    CGSize contentSize = [self collectionViewContentSize];
    BOOL isPortrait = contentSize.width < contentSize.height;
    NSInteger columns = numberOfColumns(itemsCount, isPortrait);
    
    if (itemsCount > 1) {
        
        NSInteger shiftPos = shiftPosition(itemsCount, isPortrait);
        NSInteger shift = itemIndex > shiftPos;
        
        CGFloat rows = ceilf((CGFloat)itemsCount / columns);
        NSUInteger mod = itemsCount % columns;
        
        CGFloat scale = 1.0f/columns;
        if (shiftPos == itemIndex) {
            if (columns == 2) {
                scale = 1.0f;
            }
            else if (columns == 3) {
                scale = mod == 1 ? 1.0f : (CGFloat)mod/columns;
            }
            else if (columns == 4) {
                scale = 2.0f/columns;
            }
        }
        
        CGFloat w = contentSize.width * scale;
        CGFloat h = contentSize.height / rows;
        CGFloat i = (itemIndex + shift);
        
        CGFloat row = floorf(i / columns);
        NSUInteger col = ((itemIndex + shift) % columns);
        
        return CGRectMake(w * col, h * row, w, h);
    }
    else {
        
        return CGRectMake(0, 0, contentSize.width, contentSize.height);
    }
}

static NSInteger numberOfColumns(NSInteger numberOfItems, BOOL isPortrait) {
    
    NSInteger countOfColumns;
    if (isPortrait) {
        switch (numberOfItems) {
            case 1:
            case 2:
                countOfColumns = 1;
                break;
            case 3:
            case 4:
            case 5:
            case 6:
                countOfColumns = 2;
                break;
            default:
                countOfColumns = 3;
                break;
        }
    }
    else {
        switch (numberOfItems) {
            case 1:
                countOfColumns = 1;
                break;
            case 2:
            case 4:
                countOfColumns = 2;
                break;
            case 3:
            case 5:
            case 6:
            case 9:
                countOfColumns = 3;
                break;
            default:
                countOfColumns = 4;
                break;
        }
    }
    return countOfColumns;
}

@end
